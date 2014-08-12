#
# Problem: bug-inducing changes occur in the past, while bugfixes occur in the present. Therefore, how to contrast bug-inducing and non-bug-inducing changes?
#

rm(list=ls())
source('../lib/unload-packages.R')
source('../lib/gitparser.R')
library(dplyr)

inducing <- readRDS("../raw-data/fix-inducing-commits.rds")
bugfixes <- bugfixes <- read.table("../data/bugfix-commits.csv", header=F, sep=",", quote="", col.names=c("commit", "bug_creation"), stringsAsFactors=F)
commits <- readRDS("../data/commit-log.rds")

###############

head(inducing)

###############

#total <- nrow(bugfixes)
#total
#
#induced <- length(unique(inducing$commit))
#induced
#
#inducing_mapped <- subset(inducing, commit %in% commits$commit)
#count <- length(unique(inducing_mapped$commit))
#count
#
#inducing$commit <- as.character(inducing$commit)
#
#lines <- read_lines_bz2("/tmp/x.bz2")
#all_jdt <- parse_commit_metadata(lines)
#
#class(all_jdt$hash)
#class(inducing$commit)
#
#inducing_jdt <- all_jdt %.%
#	mutate(commit = hash) %.%
#	inner_join(inducing, by="commit")
#
#summary(as.POSIXct(bugfixes$bug_creation))
#summary(inducing_jdt$time)
