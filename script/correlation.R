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

klass.release.metrics <- readRDS("../data/klass-release-metrics.rds")
klass.metrics <- readRDS("../data/klass-metrics.rds")

head(klass.release.metrics)
head(klass.metrics[, c("klass", "bugs", "violations")])

#' ## Correlation analysis

#' ### Correlation between number of violations in a release and number of bugs in the same release:

cor.test(~ bugs + violations, data=klass.release.metrics, method="spearman")

#' ### Correlation between number of violations and number of bugs (across all releases)

cor.test(~ bugs + violations, data=klass.metrics, method="spearman")

#- results='asis'

options(rcharts.cdn = TRUE)

# add 1 to allow plotting in log-scale
# add noise so we can see multiple points at the same (x, y)
n <- nrow(klass.metrics)
klass.metrics$bugs1 <- klass.metrics$bugs + 1 + runif(n, -0.1, 0.1)
klass.metrics$violations1 <- klass.metrics$violations + 1 + runif(n, -0.01, 0.01)

tooltip.fn <- "#! function(x) { 
		return(x.klass + '\\n.\\nbugs: ' + x.bugs + '\\nviolations/release: ' + x.violations); } !#";

r1 <- rPlot(bugs1 ~ violations1, data = klass.metrics, type = "point", 
	tooltip = tooltip.fn, color = "reopened")
r1$guides(
	x = list(title = "1 + avg violations per release", scale = list(type = "log")),
	y = list(title="1 + bugs", scale = list(type = "log")))
r1

#' ## Threats to validity
#'
#' * Absolute bug count is a biased metric; we should use bug density instead (bugs / lines of code). Maybe we should also take into account the number of days of a release.
#' * There's no way to be sure about the assignment between a bug and a release; as a heuristic, we assign a bug to the newest release before the bug fix.
#' * Data from some releases is missing.
#' * Possibly not all bugs are referenced in commit messages.
#'

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