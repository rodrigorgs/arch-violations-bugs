rm(list=ls())

library(DBI)
library(RMySQL)
library(plyr)
library(dplyr)
library(yaml)

##########

changed.klasses <- readRDS("../data/changed-klasses.rds")
commits <- readRDS("../data/commit-log.rds")

##########

commits.with.klasses <- changed.klasses %.% inner_join(commits)
bug.numbers <- unique(commits.with.klasses$bug) %.% na.omit()
bug.numbers <- as.integer(bug.numbers)

##########
#
# Bugs

config <- yaml.load_file("../config/db.yml")

db <- src_mysql(dbname = config$dbname, 
	host = config$host,
	port = config$port,
	user = config$user,
	password = config$password)

bugs <- tbl(db, "bugs") %.%
	filter(bug_id %in% bug.numbers) %.%
	select(bug_id, creation_ts, delta_ts, bug_status,
		resolution, version, short_desc) %.%
	collect()

bugs <- rename(bugs, c("bug_id" = "bug", 
	"creation_ts" = "initial.time",
	"delta_ts" = "final.time",
	"bug_status" = "status",
	"short_desc" = "description"))

bugs$initial.time <- as.POSIXct(bugs$initial.time)
bugs$final.time <- as.POSIXct(bugs$final.time)
bugs$version[bugs$version == "unspecified"] <- NA

bugs <- subset(bugs, version >= "3.4")

##########
#
# Reopening

field.status <- (tbl(db, "fielddefs") %.% 
	filter(name == "bug_status") %.%
	collect())$id

field.resolution <- (tbl(db, "fielddefs") %.% 
	filter(name == "resolution") %.%
	collect())$id

filtered.bug.numbers <- bugs$bug
events <- tbl(db, "bugs_activity") %.%
	filter(bug_id %in% filtered.bug.numbers,
		fieldid %in% c(field.status, field.resolution)) %.%
	select(bug_id, bug_when, fieldid, removed, added) %.%
	collect()

reopened.bug.numbers <- subset(events, added == 'REOPENED')$bug_id

##########

bugs$reopened <- bugs$bug %in% reopened.bug.numbers

saveRDS(bugs, "../data/bugs.rds")