#!/bin/sh
cd script
Rscript -e "options(repos=structure(c(CRAN='http://cran.stat.ucla.edu/'))); library(rbundler); bundle(bundle_path = '~/.Rbundle-archviol')"
cd ..
