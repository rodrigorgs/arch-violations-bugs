rm(list=ls())
source('../lib/unload-packages.R')

changed.files <- readRDS("../data/changed-files.rds")
all.klasses <- readLines("../data/klasses.txt")

changed.files$klass <- NA

klass.files <- gsub(".", "/", all.klasses, fixed=T)
klass.files <- paste0(klass.files, ".java")

klasses <- data.frame(klass=all.klasses, file=klass.files, stringsAsFactors=F)

for (i in 1:nrow(klasses)) {
	x <- klasses[i, ]
	matches <- grepl(x$file, changed.files$file, fixed=T)
	changed.files[matches, "klass"] <- x$klass
}

changed.klasses <- subset(changed.files, !is.na(klass))
changed.klasses$file <- NULL
saveRDS(changed.klasses, "../data/changed-klasses.rds")
