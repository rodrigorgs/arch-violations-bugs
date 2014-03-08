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

library(stringr)

# Parse extra bugs

reopened.bugs <- scan("../raw-data/extra-bugs-reopened.grep")
lines <- readLines("../raw-data/extra-bugs-versions.grep")
m <- str_match(lines, "^bug-(\\d+):\\s+<version>(.*?)</version>")[, c(2, 3)]

extra.bugs <- data.frame(bug = as.integer(m[, 1]), 
	initial.time = NA,
	final.time = NA,
	status = NA,
	resolution = NA,
	version = m[, 2],
	description = NA,
	reopened = NA,
	stringsAsFactors=F)
extra.bugs$version[extra.bugs$version == "unspecified"] <- NA
extra.bugs$reopened <- extra.bugs$bug %in% reopened.bugs

# Add to previous list of bugs

bugs <- readRDS("../data/bugs.rds")

bugs.extended <- rbind(bugs, extra.bugs)

saveRDS(bugs.extended, "../data/bugs-extended.rds")