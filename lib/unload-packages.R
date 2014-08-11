# Adapted from http://stackoverflow.com/questions/7505547/detach-all-packages-while-working-in-r
unload.packages <- function() {
	pkg <- names(sessionInfo()$otherPkgs)
	if (!is.null(pkg)) {
		pkg <- paste('package:', pkg, sep = "")
		lapply(pkg, detach, character.only = TRUE, unload = TRUE, force = TRUE)
	}
}

unload.packages()