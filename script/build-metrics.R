rm(list=ls())
library(reshape)
library(dplyr)
library(sqldf)

###########

commits <- readRDS("../data/commit-log.rds")
changed.klasses <- readRDS("../data/changed-klasses.rds")
releases <- readRDS("../data/eclipse-releases.rds")
violations <- readRDS("../data/violations.rds")
viol.releases <- readRDS("../data/viol-releases.rds")
bugs <- readRDS("../data/bugs-extended.rds")
klassloc <- readRDS("../data/klassloc.rds")

# violations$klass <- violations$source
# violations$klass <- violations$target
violations <- subset(violations, violtype != "---")
# violations <- subset(violations, violtype == "general")
# violations <- subset(violations, violtype == "hierarchy")
# violations <- subset(violations, violtype == "instantiation")

###########

#' # Map commits to releases commit => (commit, release)

# Option 1: via bug report
commits$bug <- as.integer(commits$bug)

commits.with.release <- commits %.%
	inner_join(bugs) %.%
	inner_join(releases, by="version") %.%
	select(commit, bug, reopened, release)

## Option 2: via commit time
# commits.with.release <- sqldf("select * from commits
# 	left join releases
# 	where time between initial_time and final_time")

head(commits.with.release, 2)

###########

#' # Count bugs per (klass, release)

bug.count <- commits.with.release %.%
	inner_join(changed.klasses) %.%
	group_by(klass, release) %.%
	summarise(bugs = n_distinct(bug),
		reopened = any(reopened)) %.%
	arrange(klass, release) %.%
	select(klass, release, bugs, reopened)

head(bug.count, 2)

###########

#' ## Count violations per (klass, release, source/target, violtype)

v <- violations
v$description <- NULL
violations.split.by.endpoint <- melt(v, id=c("violation", "violtype")) %.%
	arrange(violation) %.%
	rename(c("variable" = "endpoint", "value" = "klass"))
violations.split.by.endpoint$klass <- as.character(violations.split.by.endpoint$klass)

head(violations.split.by.endpoint, 6)

violation.count.detailed <- violations.split.by.endpoint %.%
	inner_join(viol.releases, by="violation") %.%
	group_by(klass, release, endpoint, violtype) %.%
	summarise(violations = n()) %.%
	arrange(klass, release)

nrow(violation.count.detailed)

#' TODO: use violation.count.detailed (to save klass.release.metrics.detailed)

###########

#' # Count violations per (klass, release) -- only klass that are sources of violations

violation.count <- violation.count.detailed %.%
	filter(endpoint == 'source') %.%
	group_by(klass, release) %.%
	summarise(violations = sum(violations)) %.%
	arrange(klass, release) %.%
	select(klass, release, violations)

nrow(violation.count)

###########

# klass.names <- readLines("../data/klasses.txt")
klass.names <- unique(violation.count.detailed$klass) %.% na.omit()
release.numbers <- as.numeric(1:19)
klass.x.release <- expand.grid(klass=klass.names, release=release.numbers, stringsAsFactors=F)

klass.release.metrics <- klass.x.release %.%
	left_join(releases) %.%
	left_join(bug.count) %.%
	left_join(violation.count) %.%
	left_join(klassloc, by=c("klass", "release")) %.%
	arrange(klass, release)

klass.release.metrics$violations[is.na(klass.release.metrics$violations)] <- 0
klass.release.metrics$bugs[is.na(klass.release.metrics$bugs)] <- 0
klass.release.metrics$reopened[is.na(klass.release.metrics$reopened)] <- FALSE
klass.release.metrics <- mutate(klass.release.metrics, bug_density = 1000 * bugs / loc)

nrow(klass.release.metrics)

head(klass.release.metrics, 2)

saveRDS(klass.release.metrics, "../data/klass-release-metrics.rds")

#' For each (klass, release), number of bugs, whether it was reopened, loc and so on.

###########

klass.major.metrics <- klass.release.metrics %.%
	group_by(version=substring(version, 1, 3), klass) %.%
	summarise(
		release = min(release),
		bugs = sum(bugs),
		violations = sum(violations),
		reopened = any(reopened))

nrow(klass.major.metrics)

saveRDS(klass.major.metrics, "../data/klass-major-metrics.rds")

###########

klass.metrics <- klass.release.metrics %.%
	group_by(klass) %.%
	summarise(releases_with_violations = sum(violations > 0),
		bugs = sum(bugs), 
		violations = mean(violations),
		reopened = any(reopened)) %.%
	arrange(nchar(klass))

nrow(klass.metrics)

saveRDS(klass.metrics, "../data/klass-metrics.rds")
