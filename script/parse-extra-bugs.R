# extra-bugs-versions.grep input generated from command:
#
# $ grep "<version>.*</version>" bug-* > extra-bugs-versions.grep
#
# Sould be run from scripts/bugzilla_crawler/downloads
#
# Sample of file content:
#
# bug-317886:          <version>3.6</version>
#
##########
#
# extra-bugs-reopened.grep generated from command:
#
# $ grep -l '<td>REOPENED' history-* | sort | uniq | sed -e 's/history-//' | paste -sd ' '
#
##########
#
# extra-bugs-creation.grep generated from command
#
# $ grep "<creation_ts>.*</creation_ts>" bug-* > extra-bugs-creation.grep
#

library(stringr)
library(dplyr)

# Parse extra bugs

reopened.bugs <- scan("../raw-data/extra-bugs-reopened.grep")
grep.version <- readLines("../raw-data/extra-bugs-versions.grep")
grep.creation <- readLines("../raw-data/extra-bugs-creation.grep")

versions <- str_match(grep.version, "^bug-(\\d+):\\s+<version>(.*?)</version>")[, c(2, 3)]
creations <- str_match(grep.creation, "^bug-(\\d+):\\s+<creation_ts>(.*?)</creation_ts>")[, c(2, 3)]

stopifnot(all(versions[, 1] == creations[, 1]))

extra.bugs <- data.frame(bug = as.integer(versions[, 1]), 
	initial.time = as.POSIXct(creations[, 2]),
	final.time = NA,
	status = NA,
	resolution = NA,
	version = versions[, 2],
	description = NA,
	reopened = NA,
	stringsAsFactors=F)
extra.bugs$version[extra.bugs$version == "unspecified"] <- NA
extra.bugs$reopened <- extra.bugs$bug %in% reopened.bugs

# Add to previous list of bugs

bugs <- readRDS("../data/bugs.rds")

bugs.extended <- rbind(bugs, extra.bugs)

saveRDS(bugs.extended, "../data/bugs-extended.rds")