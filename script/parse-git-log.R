rm(list=ls())
source('../lib/unload-packages.R')
source("../lib/gitparser.R")
library(stringr)

# input: log-eclipse-platform.txt.gz

# input generated from the command
# $ git log --stat=999 --pretty=format:"commit: %H | %ad | %s" --date=iso8601 --since=@{2009-06-01} | gzip > ../logs/log-eclipse-platform.txt.gz
# all git logs were concatenated, with a blank line between logs

repositories <- read.csv("../raw-data/gitrepos.csv")

#############

commit.log <- NULL
changed.files <- NULL

for (repo in repositories$gitrepo) {
	path <- paste0("../raw-data/log-", repo, ".txt.bz2")
	print(path)
	lines <- read_lines_bz2(path)

	x <- parse_commit_metadata(lines)
	x$gitrepo <- repo
	commit.log <- rbind(commit.log, x)

	y <- parse_commit_files(lines)
	changed.files <- rbind(changed.files, y)
}

if (any(duplicated(commit.log$commit))) {
	stop("Duplicated values in commit!")
}

#############

saveRDS(commit.log, "../data/commit-log.rds")
saveRDS(changed.files, "../data/changed-files.rds")
