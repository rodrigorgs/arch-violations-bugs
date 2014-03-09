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
		# loc = 0
	}
	else {
		cmd.show <- paste0("show ", rev, " master '", path, "'`:'", path, "' | cloc --csv --force-lang=java -")	
		print(cmd.show)
		csv <- system2("git", cmd.show, stdout=T)
		print(csv)
	}
	
	setwd("..")
}

setwd(curdir)