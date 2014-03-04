rm(list=ls())
library(dplyr)
library(sqldf)

###########

commits <- readRDS("../data/commit-log.rds")
changed.klasses <- readRDS("../data/changed-klasses.rds")
releases <- readRDS("../data/eclipse-releases.rds")
violations <- readRDS("../data/violations.rds")
viol.releases <- readRDS("../data/viol-releases.rds")
bugs <- readRDS("../data/bugs.rds")

###########
#
# Map commits to releases

# Option 1: via bug report
commits$bug <- as.integer(commits$bug)

commits.with.release <- commits %.%
	inner_join(bugs) %.%
	inner_join(releases, by="version")

## Option 2: via commit time
# commits.with.release <- sqldf("select * from commits
# 	left join releases
# 	where time between initial_time and final_time")

###########

bug.count <- commits.with.release %.%
	inner_join(changed.klasses) %.%
	group_by(klass, release) %.%
	summarise(bugs = n_distinct(bug)) %.%
	arrange(klass, release) %.%
	select(klass, release, bugs)

###########

violation.count <- violations %.%
	inner_join(viol.releases) %.%
	group_by(klass, release) %.%
	summarise(violations = n()) %.%
	arrange(klass, release) %.%
	select(klass, release, violations)

###########

klass.names <- unique(violations$klass) %.% na.omit()
release.numbers <- as.numeric(1:19)
klass.x.release <- expand.grid(klass=klass.names, release=release.numbers, stringsAsFactors=F)

klass.release.metrics <- klass.x.release %.%
	left_join(bug.count) %.%
	left_join(violation.count) %.%
	arrange(klass, release)

klass.release.metrics$violations[is.na(klass.release.metrics$violations)] <- 0
klass.release.metrics$bugs[is.na(klass.release.metrics$bugs)] <- 0

saveRDS(klass.release.metrics, "../data/klass-release-metrics.rds")

###########

klass.metrics <- klass.release.metrics %.%
	group_by(klass) %.%
	summarise(releases_with_violations = sum(violations > 0),
		bugs = sum(bugs), 
		violations = mean(violations)) %.%
	arrange(nchar(klass))

saveRDS(klass.metrics, "../data/klass-metrics.rds")
