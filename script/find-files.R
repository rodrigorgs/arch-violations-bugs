library(yaml)

klasses <- readLines("../data/klasses.txt")

config <- yaml.load_file("../config/gitrepo.yml")

##########
curdir <- getwd()
setwd(config$path)

write(klasses, file="listclasses123.txt", ncolumns=1)
system("for x in `cat listclasses123.txt`; do (find . | grep `echo $x | sed -e 's/[.]/\\//g'`.java) ; done | tee klasspath2.txt")
file.remove("listclasses123.txt")

f <- "klasspath2.txt" 
files <- readLines(f)

setwd(curdir)
##########

write(files, "../data/files.txt", ncolumns=1)
