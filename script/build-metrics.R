rm(list=ls())
source('../lib/summarise_grouped_metrics.R')
source('../lib/na.R')
library(reshape2)
library(dplyr)
library(sqldf)

###########

commits <- readRDS("../data/commits-with-releases.rds")
changed.klasses <- readRDS("../data/changed-klasses.rds")
releases <- readRDS("../data/eclipse-releases.rds")
violations <- readRDS("../data/violations.rds")
viol.releases <- readRDS("../data/viol-releases.rds")
bugs <- readRDS("../data/bugs-extended.rds")
klassloc <- readRDS("../data/klassloc.rds")

violations <- subset(violations, violtype != "---")

###########

commits %.% inner_join(changed.klasses) %.% head()

#' # Count bugs per (klass, release)

bug.count <- commits %.%
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
	reshape::rename(c("variable" = "endpoint", "value" = "klass"))
violations.split.by.endpoint$klass <- as.character(violations.split.by.endpoint$klass)

head(violations.split.by.endpoint, 6)

violation.count.detailed <- violations.split.by.endpoint %.%
	inner_join(viol.releases, by="violation") %.%
	group_by(klass, release, endpoint, violtype) %.%
	summarise(violations = n()) %.%
	arrange(klass, release)

nrow(violation.count.detailed)

###########

#' ## Metrics for (klass, release, source/target, violtype) => (loc, reopened, ...)

keys <- expand.grid(
	klass = unique(violation.count.detailed$klass) %.% na.omit(),
	release = unique(violation.count.detailed$release),
	endpoint = unique(violation.count.detailed$endpoint),
	violtype = unique(violation.count.detailed$violtype),
	stringsAsFactors=F)

metrics <- keys %.%
	left_join(violation.count.detailed, by=c("klass", "release", "endpoint", "violtype")) %.%
	left_join(bug.count, by=c("klass", "release")) %.%
	left_join(releases, by="release") %.%
	left_join(klassloc, by=c("klass", "release")) %.%
	mutate(
		bugs = na.as.zero(bugs),
		violations = na.as.zero(violations),
		reopened = na.as.false(reopened),
		bug_density = 1000 * bugs / loc,
		majversion = substring(version, 1, 3))

nrow(metrics)

saveRDS(metrics, "../data/metrics.rds")

###########

#' ## Metrics grouped by (klass, release)

klass.release.metrics <- metrics %.%
	group_by(klass, release) %.%
	summarise_grouped_metrics()

nrow(klass.release.metrics)

saveRDS(klass.release.metrics, "../data/klass-release-metrics.rds")

###########

#' ## Group releases by minor revision (e.g., 4.3.1 => 4.3)

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

#' ## Group metrics by class

klass.metrics <- klass.release.metrics %.%
	group_by(klass) %.%
	summarise(releases_with_violations = sum(violations > 0),
		bugs = sum(bugs), 
		violations = mean(violations),
		reopened = any(reopened)) %.%
	arrange(nchar(klass))

nrow(klass.metrics)

saveRDS(klass.metrics, "../data/klass-metrics.rds")
