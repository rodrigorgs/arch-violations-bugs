# /* Run this script with ./create-notebook.sh */

#- echo=F, results='hide', warning=F, error=F, message=F
rm(list=ls())
source('../lib/unload-packages.R')

source('../lib/rcharts-workaround.R', chdir=T)
library(dplyr)
library(sqldf)
library(rCharts)
library(ggplot2)

#- echo=T, results='markup', warning=T, error=T, message=T

#' # Number of architectural violations vs. number of bugs
#'

#' ## Data

klass.release.metrics <- readRDS("../data/klass-release-metrics.rds")
klass.metrics <- readRDS("../data/klass-metrics.rds")
klass.major.metrics <- readRDS("../data/klass-metrics.rds")

#' ## Correlation analysis

#' ### Correlation between number of violations in a class in a certain release and number of lines of code

cor.test(~ bug_density + violations, data=klass.release.metrics, method="spearman")

#' ### Correlation between num. violations and LOC, for major releases

cor.test(~ bugs + violations, data=klass.major.metrics, method="spearman")

#' ### Correlation between number of violations and number of bugs (across all releases)

cor.test(~ bugs + violations, data=klass.metrics, method="spearman")

#- scatter-bugs-violations,results='asis'

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

n <- nrow(klass.release.metrics)

ggplot(klass.release.metrics, aes(factor(violations), bug_density)) + geom_boxplot() + xlab("number of architectural violations") + ylab("bugs / KLOC") + scale_y_log10()

ggplot(klass.release.metrics, aes(factor(violations > 0), bug_density)) + geom_boxplot() + xlab("class has architectural violations?") + ylab("bugs / KLOC") + scale_y_log10()

#' ## Threats to validity
#'
#' * Absolute bug count is a biased metric; we should use bug density instead (bugs / lines of code). Maybe we should also take into account the number of days of a release.
#' * We only consider bugs that are referenced in commit logs and whose bug report's "version" field is set. This may be a source of selection bias.
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