library(stringr)

# input: log-eclipse-platform.txt.gz

# input generated from the command
# git log --stat=999 --pretty=format:"commit: %H | %ad | %s" --date=iso8601 --since=@{2009-06-01} | gzip > ../logs/log-eclipse-platform.txt.gz

file <- gzfile("../raw-data/log-eclipse-platform.txt.gz")
lines <- readLines(file)
close(file)

############################################

# index of lines that begin with commit
commit.idx <- grep("^commit", lines)

info <- lines[commit.idx]
hash <- substring(info, 9, 48)
time <- as.POSIXct(substring(info, 52, 76))
message <- substring(info, 80)
bug <- str_match(tolower(message), "\\b\\d{5,6}\\b")[, 1]

commit.log <- data.frame(commit=seq(info), hash, time, bug, message, stringsAsFactors=F)
saveRDS(commit.log, "../data/commit-log.rds")

#########################################

# index of first and last lines that contain the list of files changed, per commit
first <- commit.idx + 1
last <- c(commit.idx[-1] - 3, length(lines) - 1)
size <- 1 + (last - first)
filelist.idx <- data.frame(id=seq(first), first, last, size, stringsAsFactors=F)

# ignore commits with no files changed
filelist.idx <- subset(filelist.idx, size >= 1)

# indices of lines that contain the list of files changed
idx <- unlist(apply(filelist.idx, 1, function(x) x["first"]:x["last"]))

commit <- rep(filelist.idx$id, filelist.idx$size)
file <- lines[idx]
file <- str_match(file, "^ (.+?) +\\|")[, 2]

changed.files <- data.frame(commit, file, stringsAsFactors=F)
saveRDS(changed.files, "../data/changed-files.rds")
