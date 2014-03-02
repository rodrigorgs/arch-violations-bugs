#!/usr/bin/env ruby
require 'date'

i = 1
File.open("../data/eclipse-releases.csv", "w") do |f|
	f.puts "release,version,time"
	IO.readlines("../data/eclipse-releases-site.tsv").each do |line|
		version, time = line.split("\t")
		time = DateTime.parse(time).iso8601
		f.puts "#{i},#{version},#{time}"
		i += 1
	end
end