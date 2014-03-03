# /* Run this script with ./create-notebook.sh */

#- echo=F, results='hide', warning=F, error=F, message=F
rm(list=ls())

source('../lib/rcharts-workaround.R', chdir=T)
library(dplyr)
library(sqldf)
library(rCharts)

#- echo=T, results='markup', warning=T, error=T, message=T

#' # Number of architectural violations vs. number of bugs
#'

#' ## Data

commits <- readRDS("../data/commit-log.rds")
changed.klasses <- readRDS("../data/changed-klasses.rds")
releases <- readRDS("../data/eclipse-releases.rds")
violations <- readRDS("../data/violations.rds")
viol.releases <- readRDS("../data/viol-releases.rds")

#' Discover the release associated with each commit. For simplicity, we take the most recent release before the commit.

commits2 <- sqldf("select * from commits
	left join releases
	where time between initial_time and final_time")

#' Now, get the classes changed in each commit

commits2 <- merge(commits2, changed.klasses)

#' Number of bugs for each (klass, release):

bug.count <- commits2 %.%
	merge(changed.klasses) %.%
	group_by(klass, release) %.%
	summarise(bugs = n_distinct(bug)) %.%
	arrange(desc(bugs))

#' Number of violations for each (klass, release):

violation.count <- violations %.%
	merge(viol.releases) %.%
	select(klass, release) %.%
	group_by(klass, release) %.%
	summarise(violations = n()) %.%
	arrange(klass, release)

#' Now, unify the data so we have the number of bugs and violations for each (klass, release).

klass.names <- unique(violations$klass)
release.numbers <- 1:19
klass.x.release <- expand.grid(klass=klass.names, release=release.numbers)

df <- klass.x.release %.%
	merge(bug.count, all.x=T) %.%
	merge(violation.count, all.x=T) %.%
	arrange(klass, as.numeric(release))
df$violations[is.na(df$violations)] <- 0
df$bugs[is.na(df$bugs)] <- 0

#' Here's what it looks like

head(df)

#' Also, combine data across all releases, so we have the number of bugs and the average number of violations for each klass.

overall <- df %.%
	group_by(klass) %.%
	summarise(releases_with_violations = sum(violations > 0),
		bugs = sum(bugs), 
		violations = mean(violations))

#' ## Correlation analysis

#' ### Correlation between number of violations in a release and number of bugs in the same release:
cor.test(df$violations, df$bugs, method="spearman")

#' ### Correlation between number of violations and number of bugs (across all releases)

cor.test(overall$violations, overall$bugs, method="spearman")


#- results='asis'
options(rcharts.cdn = TRUE)

# add 1 to allow plotting in log-scale
# add noise so we can see multiple points at the same (x, y)
n <- nrow(overall)
overall$bugs1 <- overall$bugs + 1 + runif(n, -0.1, 0.1)
overall$violations1 <- overall$violations + 1 + runif(n, -0.01, 0.01)

tooltip.fn <- "#! function(x) { 
		return(x.klass + '\\n.\\nbugs: ' + x.bugs + '\\nviolations/release: ' + x.violations); } !#";

r1 <- rPlot(bugs1 ~ violations1, data = overall, type = "point", 
	tooltip = tooltip.fn, color = "releases_with_violations")
r1$guides(
	x = list(title = "1 + avg violations per release", scale = list(type = "log")),
	y = list(title="1 + bugs", scale = list(type = "log")))
r1

# /*
# add 1 to allow plotting in log-scale
# add noise so we can see multiple points at the same (x, y)
# n <- nrow(df)
# amount <- 0.3
# df$bugs1 <- df$bugs + 1 + runif(n, -amount, amount)
# df$violations1 <- df$violations + 1 + runif(n, -amount, amount)

# tooltip.fn <- "#! function(x) { 
# 		return(x.klass + '\\nrelease: ' + x.release + '\\n.\\nbugs: ' + x.bugs + '\\nviolations: ' + x.violations); } !#"

# r2 <- rPlot(bugs1 ~ violations1, data = df, type = "point", tooltip=tooltip.fn, size=list(const=3))
# r2$guides(y = list(title="1 + bugs", scale = list(type = "log")),
# 	x = list(title = "1 + violations", scale = list(type = "log")))
# r2

# r1 <- rPlot(bugs1 ~ violations1 | release, data = df, type = "point", tooltip=tooltip.fn, size=list(const=2))
# r1$guides(y = list(title="1 + bugs", scale = list(type = "log")),
# 	x = list(title = "1 + violations", scale = list(type = "log")))
# r1$addParams(height = 1000)
# r1
# */