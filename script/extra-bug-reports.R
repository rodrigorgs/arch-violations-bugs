bugs <- readRDS("../data/bugs.rds")
commits <- readRDS("../data/commit-log.rds")
commits$bug <- as.integer(commits$bug)

# Bugs referenced in the commit log for which no bug report was found

commit.bugs <- unique(subset(commits, bug > max(bugs$bug))$bug)
bugs.to.download <- setdiff(commit.bugs, bugs$bug)

# URLs for bug page and bug history

urls <- sapply(bugs.to.download, function(x) list(
	a = paste0("https://bugs.eclipse.org/bugs/show_bug.cgi?ctype=xml&id=", x),
	b = paste0("https://bugs.eclipse.org/bugs/show_activity.cgi?id=", x)))
urls <- unlist(urls)

# Write to a file the crawler can use

write(urls, file="bugzilla_crawler/urls-to-download")
