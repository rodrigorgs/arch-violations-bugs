library(dplyr)
library(yaml)

files <- readLines("../data/files.txt")
releases <- readRDS("../data/eclipse-releases.rds")

fileloc <- expand.grid(release=releases$release, file=files, stringsAsFactors=F)
fileloc <- fileloc %.% 
	inner_join(releases, by="release") %.%
	arrange(file, release) %.%
	select(release, file, initial.time) %.%
	mutate(loc=NA, loc.blank=NA, loc.comment=NA, loc.code=NA)

#######

config <- yaml.load_file("../config/gitrepo.yml")

curdir <- getwd()
setwd(config$path)

for (i in 1:nrow(fileloc)) {
	what <- fileloc[i, ]

	repo <- strsplit(what$file, "/")[[1]][2]
	path <- substring(what$file, nchar(repo) + 4)

	setwd(repo)
	cmd.rev <- paste0("rev-list -n 1 --before='", what$initial.time, "' master '", path, "'")
	print(cmd.rev)
	rev <- system2("git", cmd.rev, stdout=T)

	if (length(rev) == 0) {
		fileloc[i, c("loc", "loc.blank", "loc.comment", "loc.code")] <- 0
	}
	else {
		cmd.show <- paste0("show ", rev, " -- '", path, "' | cloc --csv --force-lang=java -")	
		print(cmd.show)

		csv <- system2("git", cmd.show, stdout=T)
		csv <- csv[c(length(csv) - 1, length(csv))]
		data <- read.csv(text=csv)

		fileloc[i, "loc.blank"] <- as.numeric(data$blank)
		fileloc[i, "loc.comment"] <- as.numeric(data$comment)
		fileloc[i, "loc.code"] <- as.numeric(data$code)
		fileloc[i, "loc"] <- sum(fileloc[i, "loc.blank"], fileloc[i, "loc.comment"], fileloc[i, "loc.code"])

		print(csv)
	}
	print(fileloc[i, ])

	setwd("..")
}

setwd(curdir)

saveRDS(fileloc, "../data/fileloc.rds")