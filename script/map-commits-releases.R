rm(list=ls())
source('../lib/unload-packages.R')
library(dplyr)

commits <- readRDS("../data/commit-log.rds")
bugs <- readRDS("../data/bugs-extended.rds")
releases <- readRDS("../data/eclipse-releases.rds")

#' # Map commits to releases: commit => (commit, release)

# Option 1: via bug report
commits$bug <- as.integer(commits$bug)

commits.with.releases <- commits %.%
	inner_join(bugs) %.%
	inner_join(releases, by="version") %.%
	select(commit, bug, reopened, release)

## Option 2: via commit time
# commits.with.releases <- sqldf("select * from commits left join releases where time between initial_time and final_time")

head(commits.with.releases, 2)

saveRDS(commits.with.releases, "../data/commits-with-releases.rds")