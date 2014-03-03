#!/usr/bin/env ruby
require 'date'

i = 0
File.open("../data/eclipse-releases.csv", "w") do |f|
	f.puts "release,version,time"
	IO.readlines("../raw-data/eclipse-releases-site.tsv").each do |line|
		release, version, time = line.split("\t")
		time = DateTime.parse(time).iso8601.gsub("T", " ")
		f.puts "#{release},#{version},#{time}"
		i += 1
	end
end