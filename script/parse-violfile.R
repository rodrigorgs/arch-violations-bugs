library(stringr)
library(dplyr)
library(reshape)

######################

lines <- readLines("../raw-data/violfile.txt")
violations <- read.csv("../data/viol-klasses.tsv", sep="\t", stringsAsFactors=F)

violations$violation <- as.numeric(violations$violation)

# Split by *
releases.str = str_match(lines, "(.+)\\*(.+)")[, c(2, 3)][, 2]
releases.list <- strsplit(releases.str, " +")

viol.releases <- data.frame(
  violation = rep(violations$violation, sapply(releases.list, length)),
  release = as.numeric(unlist(releases.list)))

saveRDS(violations, "../data/violations.rds")
saveRDS(viol.releases, "../data/viol-releases.rds")