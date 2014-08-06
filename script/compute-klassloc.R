rm(list=ls())
library(dplyr)

fileloc <- readRDS("../raw-data/fileloc.rds")
klass.files <- readRDS("../data/klass-files.rds")

klassloc <- fileloc %.%
	inner_join(klass.files, by="file") %.%
	group_by(klass, release) %.%
	summarise(loc = sum(loc),
		loc.blank = sum(loc.blank),
		loc.comment = sum(loc.comment),
		loc.code = sum(loc.code)) %.%
	arrange(klass, release)

saveRDS(klassloc, "../data/klassloc.rds")