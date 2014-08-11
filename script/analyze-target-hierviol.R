rm(list=ls())
source('../lib/unload-packages.R')
library(dplyr)

#' Which bugs/klasses are target of hierarchy violations? which of these were reopened, which were not?

commits <- readRDS("../data/commits-with-releases.rds")
changed.klasses <- readRDS("../data/changed-klasses.rds")
bugs <- readRDS("../data/bugs-extended.rds")

commits$bug <- as.numeric(commits$bug)
bugs$bug <- as.numeric(bugs$bug)

# violations <- subset(violations, violtype != "---")

metrics <- readRDS("../data/metrics.rds")

targhier <- subset(metrics, endpoint == "target" & violtype == "hierarchy" & violations > 0)

######################

# reopened <- subset(targhier, reopened)

bugs.kr <- commits %.%
	inner_join(changed.klasses, by="commit") %.%
	inner_join(bugs) %.%
	group_by(klass, release, bug, description) %.%
	summarise(reopened = any(reopened)) %.%
	arrange(klass, release) #%.%
	# select(klass, release, bug, reopened)

x <- bugs.kr %.%
	inner_join(targhier, by=c("klass", "release", "reopened")) %.%
	arrange(reopened, bug) %.%
	select(klass, release, reopened, bug, description)

# nrow(x)
# print.data.frame(x[, c("klass", "bug", "reopened")])


clip <- pipe("pbcopy", "w")
write.table(x, file=clip, sep="\t")
close(clip)
# View(x)

#' # PROBLEM:

#' Maybe the result is biased by the fact that there's one single bug with multiple violation classes (bug 395213)