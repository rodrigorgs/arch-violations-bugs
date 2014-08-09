na.as.zero <- function(x) {
  x[is.na(x) | is.null(x)] <- 0
  x
}

na.as.false <- function(x) {
  x[is.na(x) | is.null(x)] <- FALSE
  x
}

na.as.true <- function(x) {
  x[is.na(x) | is.null(x)] <- TRUE
  x
}