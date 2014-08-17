#' Are commits that touch classes that are eventually involved in architectural violations more likely to induce bugfixes?

# TODO: select only commits in the period for which we have violation reports, so we can determine if commit touched a class that violated architecture when the commit was performed.

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

indcommits <- subset(commits, commit %in% induction$inducing)
nrow(indcommits)
stopifnot(nrow(indcommits) == length(unique(induction$inducing)))

remove.packages <- function(s) {
	gsub(".*[.]", "", s)
}

# Provide additional info about commits identified by `hashes`.
# violklasses is a list of klasses that are involved in architectural violations.
detail.commits <- function(hashes, violklasses) {
	a <- changed.klasses %>%
		filter(commit %in% hashes) %>%
		mutate(violate = klass %in% violklasses) %>%
		group_by(commit) %>%
		summarise(
			nklasses = n(),
			nviolklasses = sum(violate),
			nameviolklasses = paste(remove.packages(klass[violate]), collapse=" ")) %>%
		inner_join(commits) %>%
		select(gitrepo, time, commit,
			message, bug,
			nklasses, nviolklasses, nameviolklasses)
	a
}

# type <- "instantiation"
# endpoint <- "target"
cases <- NULL

for (type in unique(violations$violtype)) {
	for (endpoint in c("source", "target")) {
		v <- violations[violations$violtype == type, endpoint]
		changed.klasses$touches_violklass <- changed.klasses$klass %in% v

		commit_violation <- changed.klasses %.%
			group_by(commit) %.%
			summarise(touches_violklass = any(touches_violklass),
				nclasses = n())

		###

		x <- commits %.%
			inner_join(commit_violation, by="commit") %.%
			mutate(inducing = commit %in% indcommits$commit)

		head(x)
		t <- xtabs(~ touches_violklass + inducing, data=x)
		print(fisher.test(t)$p.value)
		png(paste0("../report/abc-", endpoint, "-", type, ".png"))
		mosaicplot(t, main=paste(endpoint, type, fisher.test(t)$p.value < 0.05))
		dev.off()

		# Collect cases for further analysis
		a <- detail.commits(induction$inducing, v)
		names(a) <- paste0("A_", names(a))
		b <- detail.commits(induction$commit, v)
		names(b) <- paste0("B_", names(b))

		y <- induction %>%
			select(A_commit = inducing, B_commit = commit) %>%
			inner_join(a) %>%
			inner_join(b) %>%
			mutate(violtype = type, violendpoint = endpoint) %>%
			select(
				violtype, violendpoint,
				A_gitrepo, A_time, A_commit,
				A_message, A_bug,
				A_nklasses, A_nviolklasses, A_nameviolklasses,
				B_gitrepo, B_time, B_commit,
				B_message, B_bug,
				B_nklasses, B_nviolklasses, B_nameviolklasses) %>%
			filter(A_nviolklasses > 0)
			
		cases <- rbind(cases, y)
	}
}

write.csv(cases, "../data/inducing-cases.csv")

# Yes! Commits that touch klasses that are eventually involved in violations are more likely to contain bugs.

#' However, bugs may not be actual bugs (they may be refactoring requests, for example, or even changes in the licensing comments in the header of each source file)

# TODO: reopening

commits$bug <- as.integer(commits$bug)

# induction => commits => bugs => @reopened
mega <- induction %.%
	select(inducing) %.%
	inner_join(commits, by="commit") %.%
	select(bugfixcommit = commit, bugfixhash = commit, commit = inducing, bugfixbug = bug) %.%
	inner_join(commits, by="commit") %.%
	select(bugfixcommit, bugfixhash, bug = bugfixbug, indcommit = commit, indhash = commit) %.%
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