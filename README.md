Study on the association between number of architectural violations and bugs.

## Configuration

You'll need R with the following packages installed:

* dplyr
* RMySQL
* sqldf
* yaml
* knitr
* markdown
* stringr
* reshape
* rCharts
* ggplot2
* vioplot

Also, you'll need to configure your MySQL database and git repositories using the files in `config/`.

## Project structure

Folders:

* `report/` - reports created by scripts
* `script/` - scripts to transform data and create reports
* `lib/` - reusable functions
* `data/` - data created by scripts from raw data
* `raw-data/` - raw data, manually created
* `doc/` - developer documentation (data and processing pipeline)
* `config/` - configuration files

## Authors

* João Arthur <joaoarthurbm@gmail.com>
* Rodrigo Souza <rodrigorgs@gmail.com>
