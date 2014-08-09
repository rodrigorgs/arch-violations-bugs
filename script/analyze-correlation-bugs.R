rm(list=ls())
source('../lib/summarise_grouped_metrics.R')
source('../lib/na.R')
library(dplyr)

star.significant <- function(x) ifelse(x <= 0.05, '*', ' ')

#' # Load metrics

metrics <- readRDS("../data/metrics.rds")

#' Group metrics by major version

metrics <- metrics %.%
	group_by(klass, endpoint, violtype, majversion) %.%
	summarise_grouped_metrics()

#' # Compute metrics filtering by endpoint and violtype

keys <- unique(metrics[, c("endpoint", "violtype")], stringsAsFactors=F)
keys <- keys %.% rbind(data.frame(endpoint=unique(metrics$endpoint), violtype=NA))
keys <- keys %.% rbind(data.frame(endpoint=NA, violtype=unique(metrics$violtype)))
keys <- keys %.% rbind(data.frame(endpoint=NA, violtype=NA))

#' For each (klass, majversion)...

num.klass.releases <- nrow(unique(metrics[, c("klass", "majversion")]))
for (row in 1:nrow(keys)) {
	sel.endpoint <- keys[row, "endpoint"]
	sel.violtype <- keys[row, "violtype"]

	m <- subset(metrics,
		(is.na(sel.endpoint) | endpoint == sel.endpoint) & 
		(is.na(sel.violtype) | violtype == sel.violtype))
	

	#' filter by endpoint and/or violtype
	if (is.na(sel.endpoint) | is.na(sel.violtype)) {
		m <- m %.%
			group_by(klass, majversion) %.%
			summarise_grouped_metrics()
	}

	stopifnot(nrow(m) == num.klass.releases)

	#' Compute correlation btw bug_density and number of violations

	cortest <- cor.test(~ bug_density + violations, 
		data=m, method="spearman")
	keys[row, "cor.bugs"] <- cortest$estimate
	keys[row, "p1"] <- star.significant(cortest$p.value)

	##

	# wil <- wilcox.test(bug_density ~ I(m$violations > 0), data=m)
	# keys[row, "wil.bugs"] <- subset(m, violations > 0)$bug_density %.% mean(na.rm=T) -
	# 	subset(m, !(violations > 0))$bug_density %.% mean(na.rm=T)
	# keys[row, "p2"] <- star.significant(wil$p.value)

	##

	#' Compute association btw existence of bugs and existence of violations

	t <- xtabs(~ I(bugs > 0) + I(violations > 0), data=m)
	f <- fisher.test(t)
	keys[row, "fisher.bugs"] <- f$estimate
	keys[row, "p3"] <- star.significant(f$p.value)

	##

	#' Compute association btw reopening and existence of violations

	t <- xtabs(~ reopened + I(violations > 0), data=m)
	f <- fisher.test(t)
	keys[row, "fisher.reop"] <- f$estimate
	keys[row, "p4"] <- star.significant(f$p.value)
}

keys

#' p1, p2, p3, and p4 are p-values.
