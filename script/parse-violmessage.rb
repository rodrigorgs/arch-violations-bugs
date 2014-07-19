#!/usr/bin/env ruby

TYPE = /
  # First component
  \w+
  # Additional components separated by .
  (?:\.[\w\$]+)*/x

METHOD = /
  # Method name
  \w+
  # Parameter list
  \(.*?\)/x

ENVIRONMENT = /[^ ]+/
VERSION = /[^ ]+/
BUNDLE = /[^ ]+/

# violation types:
# - extends/implements
# - instantiates
# - wrong parameter
# - references
# - API vs non-API

# http://stackoverflow.com/questions/2587076/eclipse-warning-methodname-has-non-api-return-type-parameterizedtype

## Violation types:
violtypes = %w(
inheritance instantiate api api inheritance environment environment reference
inheritance api api api api inheritance inheritance --- reference inheritance
--- environment --- --- inheritance)

templates = [
  /^(?<source>#{TYPE}) illegally extends (?<target>#{TYPE})$/,
  /^(?<source>#{TYPE}) illegally instantiates (?<target>#{TYPE})$/,
  /^(?<source>#{TYPE}) extends non-API type (?<target>#{TYPE})$/,
  /^(?<source>#{TYPE})\.#{METHOD} has non-API parameter type (?<target>#{TYPE})$/,
  /^(?<source>#{TYPE}) illegally implements (?<target>#{TYPE})$/,
  /^The method (?<target>#{TYPE})\.#{METHOD} referenced in (?<source>#{TYPE})\.#{METHOD} is not defined in the bundle's required execution environment: #{ENVIRONMENT}$/,
  /^The type (?<target>#{TYPE}) referenced in (?<source>#{TYPE})\.#{METHOD} is not defined in the bundle's required execution environment: #{ENVIRONMENT}$/,
  /^(?<source>#{TYPE}) illegally references method (?<target>#{TYPE})\.#{METHOD}$/,
  /^An anonymous type defined in (?<source>#{TYPE})\.#{METHOD} illegally extends (?<target>#{TYPE})$/,
  /^(?<source>#{TYPE}) declared as non-API type (?<target>#{TYPE})$/,
  /^(?<source>#{TYPE})\.#{METHOD} has non-API return type (?<target>#{TYPE})$/,
  /^(?<source>#{TYPE}) implements non-API interface (?<target>#{TYPE})$/,
  /^Constructor for (?<source>#{TYPE}) with non-API parameter type (?<target>#{TYPE})$/,
  /^(?<source>#{TYPE}) illegally implements (?<target>#{TYPE}) via #{TYPE}$/,
  /^An anonymous type defined in (?<source>#{TYPE}) illegally extends (?<target>#{TYPE})$/,
  /^The method (?<source>#{TYPE})\.#{METHOD} that has to be implemented has been added$/,
  /^(?<source>#{TYPE}) illegally references constructor (?<target>#{TYPE})$/,
  /^An anonymous type defined in (?<source>#{TYPE})\.#{METHOD} illegally implements (?<target>#{TYPE})$/,
  /^The method (?<source>#{TYPE})\.#{METHOD} in an interface that is intended to be implemented has been added$/,
  /^The constructor (?<target>#{TYPE})\.#{METHOD} referenced in (?<source>#{TYPE})\.#{METHOD} is not defined in the bundle's required execution environment: #{ENVIRONMENT}$/,
  /^The visibility of the method (?<source>#{TYPE})\.#{METHOD} has been reduced$/,
  /^The minor version should be incremented in version #{VERSION} because reexported bundle #{BUNDLE} has changed its minor version$/,
  /^An anonymous type defined in (?<source>#{TYPE}) illegally implements (?<target>#{TYPE})$/]

def match_one(text, regexes)
  matches = []
  index = 0
  regexes.each do |regex|
    m = regex.match(text)
    if !m.nil?
      matches << m
      yield index
    end
    index += 1
  end
  raise RuntimeError, "A string matches two regexes: '#{text}'" if matches.size > 1
  return matches.empty? ? nil : matches[0]
end

if __FILE__ == $0
  results = []
  klasses = []
  i = 0
  IO.readlines('../raw-data/violfile.txt').each do |line|
    i += 1
    line.chomp!
    line.gsub!(/\*.*$/, '')
    # Replace strange numbers that appear on some signatures, e.g. SWT_AWT_.11.
    line.gsub!(/\.\d+\./, '.method')

    violtype = nil
    m = match_one(line, templates) do |index|
      violtype = violtypes[index]
    end
    raise RuntimeError, "No match for #{line}" if m.nil?

    # remove internal class names (after $)
    source = m.names.include?('source') ? m['source'] : nil
    source = source.gsub(/\$[^.]+/, '') if source
    target = m.names.include?('target') ? m['target'] : nil
    target = target.gsub(/\$[^.]+/, '') if target
    
    results << [i, line, violtype, source, target]
    klasses << source unless source.nil?
    klasses << target unless target.nil?
  end

  puts "#{i} line(s) processed."

  File.open('../data/viol-klasses.tsv', 'w') do |f|
    f.puts "violation\tdescription\tvioltype\tsource\ttarget"
    f.puts results.map { |l| l.join("\t") }.join("\n")
  end
  File.open('../data/klasses.txt', 'w') { |f| f.puts klasses.sort.uniq.join("\n") }
end
