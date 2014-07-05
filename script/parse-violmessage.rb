#!/usr/bin/env ruby

TYPE = /
  # First component
  \w+
  # Additional components separated by .
  (?:\.[\w\$]+)*/x

METHOD = /
  # Method name
  \w+
  # Strange numbers that appear on SWT_AWT_.11.
  (?:\.\d+\.)?
  # Parameter list
  \(.*?\)/x

ENVIRONMENT = /[^ ]+/
VERSION = /[^ ]+/
BUNDLE = /[^ ]+/


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
  regexes.each do |regex|
    m = regex.match(text)
    matches << m unless m.nil?
  end
  raise RuntimeError, "A string matches two regexes: '#{text}'" if matches.size > 1
  return matches.empty? ? nil : matches[0]
end

if __FILE__ == $0
  results = []
  IO.readlines('../raw-data/violfile.txt').each do |line|
    line.chomp!
    line.gsub!(/\*.*$/, '')

    line.gsub!(/\.\d+\./, '.method')
    next if line =~ /^The minor version should be incremented in version.*/

    m = match_one(line, templates)
    raise RuntimeError, "No match for #{line}" if m.nil?

    source = m['source'].gsub(/\$[^.]+/, '')
    target = m.names.include?('target') ? m['target'] : nil
    target = target && target.gsub(/\$[^.]+/, '')
    results << [line, source, target]
  end

  File.open('../data/viol-klasses.tsv', 'w') do |f|
    f.puts "description\tsource\ttarget"
    f.puts results.map { |l| l.join("\t") }.join("\n")
  end
end
