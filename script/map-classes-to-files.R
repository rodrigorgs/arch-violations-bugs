files <- readLines("../raw-data/files.txt")
klasses <- readLines("../data/klasses.txt")

klass.files <- data.frame(file=files, klass=NA, stringsAsFactors=F)

for (klass in klasses) {
	path <- paste0(gsub(".", "/", klass, fixed=T), ".java")
	matches <- grep(path, klass.files$file, fixed=T)
	klass.files[matches, "klass"] <- klass
}

saveRDS(klass.files, "../data/klass-files.rds")