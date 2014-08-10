library(dplyr)

releases <- read.csv("../data/eclipse-releases.csv", stringsAsFactors=F)

releases$release <- as.numeric(releases$release)
releases$initial.time <- as.POSIXct(releases$time)
releases <- releases %.% arrange(initial.time)
releases$final.time <- c(releases$initial.time[-1] - 1, as.POSIXct("2013-09-11 10:00:00-04:00") - 1)
releases$time <- NULL

saveRDS(releases, "../data/eclipse-releases.rds")