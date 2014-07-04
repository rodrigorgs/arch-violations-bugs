#!/usr/bin/env ruby

# TODO: strip component after $, e.g. org.eclipse.ant.Test$1

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
  /^The minor version should be incremented in version #{VERSION} because reexported bundle (?<source>#{TYPE}) has changed its minor version$/,
  /^An anonymous type defined in (?<source>#{TYPE}) illegally implements (?<target>#{TYPE})$/]

# x = "org.eclipse.Java$Internal illegally extends com.sun.Sun"
# m = templates[0].match(x)
# p m
# p TYPE.match("org.ads.asd.Asd")

# x = "An anonymous type defined in org.eclipse.compare.CompareViewerPane.createTopLeft(Composite) illegally extends CLabel"
# re = /^An anonymous type defined in (?<source>#{TYPE})\.#{METHOD} illegally extends (?<target>#{TYPE})$/
# m = re.match(x)
# m['qwe']
# p m
# exit 1

def match_one(text, regexes)
  matches = []
  regexes.each do |regex|
    m = regex.match(text)
    matches << m unless m.nil?
  end
  raise RuntimeError, "A string matches two regexes: '#{text}'" if matches.size > 1
  return matches.empty? ? nil : matches[0]
end

IO.readlines('../raw-data/violfile.txt').each do |line|
  line.chomp!
  line.gsub!(/\*.*$/, '')

  m = match_one(line, templates)
  # puts line if m.nil?
  puts m.nil? ? 'nil' : "#{m['source']} --- #{m.names.include?('target') ? m['target'] : 'nil'}"
end
