#- echo=F, results='hide', warning=F, error=F, message=F
library(vioplot)
#- echo=T, results='markup', warning=T, error=T, message=T

#' # Are reopenings associated with architectural violations?

#' ## Data

klass.release.metrics <- readRDS("../data/klass-release-metrics.rds")
head(klass.release.metrics)

#' ## Number of violations

#' First, let's see if classes with reopened bugs tend to have more architectural violations:

#- reopening-viol
# /* boxplot(I(1+violations) ~ reopened, data=klass.release.metrics, log="y") */
vioplot(subset(klass.release.metrics, !reopened)$violations,
	subset(klass.release.metrics, reopened)$violations)

wilcox.test(violations ~ reopened, data=klass.release.metrics, conf.int=T, alt="greater")

#' The Wilcoxon rank sum test shows that the data does not support the hypothesis. The difference in the number of violations is tiny.

#' ## Presence of violations

#' Next, let's see if bugs found in classes with architectural violations are more likely to be reopened (when compared to bugs in classes without architectural violations):

klass.release.metrics$has.violations <- klass.release.metrics$violations > 0

t <- xtabs(~ has.violations + reopened , data=klass.release.metrics)

rates <- c(t[1, 2] / t[1, 1], t[2, 2] / t[2, 1])
names(rates) <- c("classes without violations", "classes with violations")
midpoints <- barplot(rates, main="Percent classes with reopened bugs")
text(midpoints, min(rates)/2, labels=sprintf("%.2f%%", rates*100))

fisher.test(t, alt="greater")

#' It appears that classes with violations are more likely to have reopened bugs.