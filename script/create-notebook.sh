#!/bin/bash

FILENAME=$1
BASENAME=${FILENAME##*/}
BASENAME=${BASENAME%%.*}

if [ x$1 == x ]; then
  echo ""
  echo Creates a report from a R script at ../report, using knitr::spin.
  echo Usage: `basename $0` R-file
  echo ""
  exit 0
fi

cp $FILENAME ../report/r$BASENAME.R
cd ../report

Rscript -e "library(knitr); library(markdown); knitr::spin('r$BASENAME.R'); markdownToHTML('r$BASENAME.md', 'r$BASENAME.html')"
rm r$BASENAME.md
rm r$BASENAME.R
mv r$BASENAME.html $BASENAME.html

# Fix rCharts bug
sed -i ".bak" -e 's/\\\\n/\\n/g' figure/*.html
rm figure/*.bak

cd -
