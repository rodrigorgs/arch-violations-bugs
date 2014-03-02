# input:
# * violfile.txt
#
# outputs:
# * violations.rds
# * viol-releases.rds

library(stringr)
library(dplyr)
library(reshape)

######################

REGEX.CLASS <- paste0(
  # border of a word
  "\\b", 
  # begins with org.eclipse
  "org.eclipse", 
  # matches all sub packages, e.g. ".ant.core"
  "(?:.[a-z][a-zA-Z0-9]+)+", 
  # matches class name
  "[\\.[A-Z][a-zA-Z0-9]+")

#####################

lines <- readLines("../data/violfile.txt")

# Split by *
x <- str_match(lines, "(.+)\\*(.+)")[, c(2, 3)]
violations <- data.frame(id=seq(lines), description=x[, 1], releases=x[, 2], stringsAsFactors=F)
m <- str_match(violations$description, REGEX.CLASS)
violations$source <- m[, 1]

releases.list <- strsplit(violations$releases, " +")
viol.releases <- data.frame(
  id = rep(violations$id, sapply(releases.list, length)), 
  version = unlist(releases.list))

saveRDS(violations, "../data/violations.rds")
saveRDS(viol.releases, "../data/viol-releases.rds")