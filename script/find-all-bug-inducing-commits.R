rm(list=ls())
source('../lib/unload-packages.R')
library(yaml)

bugfixes <- read.table("../data/bugfix-commits.csv", header=F, sep=",", quote="", col.names=c("commit", "bug_creation"))
gitrepos <- read.csv("../raw-data/gitrepos.csv")

###########

repoconfig <- yaml.load_file("../config/gitrepo.yml")

repo <- "eclipse.jdt.debug"

inducing <- NA

# for (repo in c("eclipse.jdt.debug")) {
for (repo in gitrepos$gitrepo) {
	path.to.repo <- paste0(repoconfig$path, "/", repo)

	isdir = file.info(path.to.repo)$isdir
	if (is.na(isdir) | isdir == FALSE) {
		print(paste0("Skipping ", path.to.repo))
		next
	}

	cmd <- paste0("./find-bug-inducing-commits.rb ", path.to.repo, " ../data/bugfix-commits.csv")
	output.lines <- system(cmd, intern=T, show.output.on.console=T)

	con <- textConnection(paste(output.lines, "\n"))
	data <- read.table(con, sep=",", header=T, stringsAsFactors=F)
	close(con)

	data$gitrepo <- repo

	if (is.na(inducing)) {
		inducing <- data
	} else {
		inducing <- rbind(inducing, data)
	}

	# head(output.lines, 100)
	# print(output.lines)
}

###########

saveRDS(inducing, "../raw-data/fix-inducing-commits.rds")