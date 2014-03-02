#!/usr/bin/env ruby
require 'date'

i = 1
File.open("../data/eclipse-releases.csv", "w") do |f|
	f.puts "release,version,date"
	IO.readlines("../data/eclipse-releases-site.tsv").each do |line|
		version, date = line.split("\t")
		date = DateTime.parse(date).iso8601
		f.puts "#{i},#{version},#{date}"
		i += 1
	end
end