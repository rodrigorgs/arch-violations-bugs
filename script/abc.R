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

# TODO: read a sample of fix-inducing commits that change classes involved in violations and the corresponding bug reports and their git blame.

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
		mosaicplot(t, main=paste(endpoint, type, fisher.test(t)$p.value < 0.05)))
		dev.off()
	}
}

# Yes! Commits that touch klasses that are eventually involved in violations are more likely to contain bugs.

# TODO: reopening

commits$bug <- as.integer(commits$bug)

# induction => commits => bugs => @reopened
mega <- induction %.%
	select(hash = commit, inducing) %.%
	inner_join(commits, by="hash") %.%
	select(bugfixcommit = commit, bugfixhash = hash, hash = inducing, bugfixbug = bug) %.%
	inner_join(commits, by="hash") %.%
	select(bugfixcommit, bugfixhash, bug = bugfixbug, indcommit = commit, indhash = hash) %.%
	inner_join(bugs, by="bug") %.%
	select(bugfixcommit, bugfixhash, bug, indcommit, indhash, reopened)

stopifnot(nrow(mega) == nrow(induction))

head(mega)

endpoint = "source"
type = "general"
for (type in unique(violations$violtype)) {
	for (endpoint in c("source", "target")) {
		v <- violations[violations$violtype == type, endpoint]
		changed.klasses$touches_violklass <- changed.klasses$klass %in% v

		commit_violation <- changed.klasses %.%
			group_by(commit) %.%
			summarise(touches_violklass = any(touches_violklass))

		###

		x <- mega %.%
			select(bugfixcommit, bugfixhash, bug, commit = indcommit, indhash, reopened) %.%
			inner_join(commit_violation, by="commit") %.%
			mutate(inducing = commit %in% indcommits$commit)

		head(x)
		t <- xtabs(~ touches_violklass + reopened, data=x)
		t
		print(fisher.test(t)$p.value)
		png(paste0("../report/abc-reopen-", endpoint, "-", type, ".png"))
		mosaicplot(t, main=paste("reop", endpoint, type, fisher.test(t)$p.value < 0.05))
		dev.off()
	}
}