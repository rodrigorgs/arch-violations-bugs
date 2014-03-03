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

lines <- readLines("../raw-data/violfile.txt")

# Split by *
x <- str_match(lines, "(.+)\\*(.+)")[, c(2, 3)]
description <- x[, 1]
releases.str <- x[, 2]

violations <- data.frame(violation=seq(lines), description=description, stringsAsFactors=F)
m <- str_match(violations$description, REGEX.CLASS)
violations$klass <- m[, 1]

releases.list <- strsplit(releases.str, " +")
viol.releases <- data.frame(
  violation = rep(violations$violation, sapply(releases.list, length)), 
  release = as.numeric(unlist(releases.list)))

saveRDS(violations, "../data/violations.rds")
saveRDS(viol.releases, "../data/viol-releases.rds")