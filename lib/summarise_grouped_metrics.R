library(dplyr)

summarise_grouped_metrics <- function(grouped_metrics) {
	grouped_metrics %.%
		summarise(
			violations = sum(violations),
			bugs = sum(bugs),
			reopened = any(reopened),
			version = max(version),
			initial.time = min(initial.time),
			final.time = max(final.time),
			loc.blank = mean(loc.blank),
			loc = mean(loc),
			loc.comment = mean(loc.comment),
			loc.code = mean(loc.code),
			bug_density = mean(bug_density))
}
