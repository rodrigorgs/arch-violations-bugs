# Workaround for \n bug
# See https://github.com/ramnathv/rCharts/issues/366

rprint <- function(rplot.obj) {
	html <- rplot.obj$render()
	html <- gsub("\\\\", "\\", html, fixed=T)
	html	
}

rrender <- function(rplot.obj, file) {
	html <- rprint(rplot.obj)
	cat(html, file=file)
}

rview <- function(rplot.obj) {
	file <- tempfile(fileext = ".html")
	rrender(rplot.obj, file)
	browseURL(file)
}