#!/usr/bin/env ruby

# https://eclipse.googlesource.com/pde/eclipse.pde.ui/+/332772_problem_filters_on_use_scan/apitools/org.eclipse.pde.api.tools/src/org/eclipse/pde/api/tools/internal/problems/problemmessages.properties

ret = []

IO.readlines('../raw-data/violfile.txt').each do |line|
  line.chomp!
  line.gsub!(/\*.*$/, '')
  line.gsub!(/(org|java|com)[.][^ ]*?\(.*?\)/, 'METHOD')
	line.gsub!(/(org|java|com)[.][^ ]*/, 'TYPE')
  line.gsub!(/(implements|extends) [^ ]*$/, '\1 TYPE')
  line.gsub!(/execution environment: .*/, 'execution environment: ENVIRONMENT')
  line.gsub!(/in version [^ ]*/, 'in version VERSION')

  ret << line
end

counts = Hash.new(0)

ret.each do |line|
  counts[line] += 1
end

result = counts.to_a.sort_by { |x, y| y }.reverse.map { |x, y| "#{y}\t#{x}"}.join("\n")
File.open('../data/violtypes.txt', 'w') do |f|
  f.puts result
  puts result
end

#ret = ret.sort.uniq
#ret = ret.sort
#puts ret.join("\n")