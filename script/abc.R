#' Are commits that touch classes that are eventually involved in architectural violations more likely to induce bugfixes?

rm(list=ls())
source('../lib/unload-packages.R')
source('../lib/gitparser.R')
library(dplyr)

#
# Problem: bug-inducing changes occur in the past, while bugfixes occur in the present. Therefore, how to contrast bug-inducing and non-bug-inducing changes?
#

induction <- readRDS("../raw-data/fix-inducing-commits.rds")
commits <- readRDS("../data/commit-log.rds")
changed.klasses <- readRDS("../data/changed-klasses.rds")
violations <- readRDS("../data/violations.rds")
violations <- subset(violations, violtype != '---')
bugs <- readRDS("../data/bugs-extended.rds")
head(bugs)
###############

# # Find commits that induced bugs

indcommits <- subset(commits, hash %in% induction$inducing)
nrow(indcommits)
stopifnot(nrow(indcommits) == length(unique(induction$inducing)))

# # Determine, for each commit, if it touched a klass that eventually
# violated the architecture.

# TODO: reopening
# TODO: look at a sample of fix-inducing commits that change classes involved in violations

for (type in unique(violations$violtype)) {
	for (endpoint in c("source", "target")) {
		v <- violations[violations$violtype == type, endpoint]
		changed.klasses$touches_violklass <- changed.klasses$klass %in% v

		commit_violation <- changed.klasses %.%
			group_by(commit) %.%
			summarise(touches_violklass = any(touches_violklass))

		###

		x <- commits %.%
			inner_join(commit_violation, by="commit") %.%
			mutate(inducing = commit %in% indcommits$commit)

		head(x)
		t <- xtabs(~ touches_violklass + inducing, data=x)
		print(fisher.test(t)$p.value)
		png(paste0("../report/abc-", endpoint, "-", type, ".png"))
		mosaicplot(t, main=paste(endpoint, type))
		dev.off()
	}
}

# Yes! Commits that touch klasses that are eventually involved in violations are more likely to contain bugs.
