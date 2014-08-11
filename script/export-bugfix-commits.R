rm(list=ls())
source('../lib/unload-packages.R')
library(dplyr)

commits <- readRDS("../data/commit-log.rds")
bugs <- readRDS("../data/bugs-extended.rds")

commits$bug <- as.integer(commits$bug)

#'
#' TODO (requirements):
#'
#' * for each commit, record original repository URL
#'

########################

bugfix.commits <- commits %.%
	inner_join(bugs, by="bug") %.%
	select(hash, initial.time)

stopifnot(sum(is.na(bugfix.commits$initial.time)) == 0)

########################

write.table(bugfix.commits, "../data/bugfix-commits.csv", col.names=F, sep=",", row.names=F, quote=F)
