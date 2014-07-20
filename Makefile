all: data/bugs-extended.rds data/bugs.rds data/changed-files.rds data/changed-klasses.rds data/commit-log.rds data/eclipse-releases.csv data/eclipse-releases.rds data/fileloc.rds data/klass-files.rds data/klass-major-metrics.rds data/klass-metrics.rds data/klass-release-metrics.rds data/klasses.txt data/klassloc.rds data/viol-klasses.tsv data/viol-releases.rds data/violations.rds data/violtypes.txt report/build-metrics.html report/compute-klassloc.html report/correlation.html report/count-loc.html report/extra-bug-reports.html report/find-files.html report/map-bug-reports.html report/map-changed-classes.html report/map-classes-to-files.html report/parse-extra-bugs.html report/parse-git-log.html report/parse-release-dates.html report/parse-violfile.html report/reopening.html report/timeseries.html

clean:
	rm -f data/bugs-extended.rds data/bugs.rds data/changed-files.rds data/changed-klasses.rds data/commit-log.rds data/eclipse-releases.csv data/eclipse-releases.rds data/fileloc.rds data/klass-files.rds data/klass-major-metrics.rds data/klass-metrics.rds data/klass-release-metrics.rds data/klasses.txt data/klassloc.rds data/viol-klasses.tsv data/viol-releases.rds data/violations.rds data/violtypes.txt report/build-metrics.html report/compute-klassloc.html report/correlation.html report/count-loc.html report/extra-bug-reports.html report/find-files.html report/map-bug-reports.html report/map-changed-classes.html report/map-classes-to-files.html report/parse-extra-bugs.html report/parse-git-log.html report/parse-release-dates.html report/parse-violfile.html report/reopening.html report/timeseries.html

data/klass-release-metrics.rds: data/commit-log.rds data/changed-klasses.rds data/eclipse-releases.rds data/violations.rds data/viol-releases.rds data/bugs-extended.rds data/klassloc.rds data/klasses.txt script/build-metrics.R
	./run-script.rb script/build-metrics.R

data/klass-major-metrics.rds: data/commit-log.rds data/changed-klasses.rds data/eclipse-releases.rds data/violations.rds data/viol-releases.rds data/bugs-extended.rds data/klassloc.rds data/klasses.txt script/build-metrics.R
	./run-script.rb script/build-metrics.R

data/klass-metrics.rds: data/commit-log.rds data/changed-klasses.rds data/eclipse-releases.rds data/violations.rds data/viol-releases.rds data/bugs-extended.rds data/klassloc.rds data/klasses.txt script/build-metrics.R
	./run-script.rb script/build-metrics.R

report/build-metrics.html: data/commit-log.rds data/changed-klasses.rds data/eclipse-releases.rds data/violations.rds data/viol-releases.rds data/bugs-extended.rds data/klassloc.rds data/klasses.txt script/build-metrics.R
	./run-script.rb script/build-metrics.R

data/klassloc.rds: data/fileloc.rds data/klass-files.rds script/compute-klassloc.R
	./run-script.rb script/compute-klassloc.R

report/compute-klassloc.html: data/fileloc.rds data/klass-files.rds script/compute-klassloc.R
	./run-script.rb script/compute-klassloc.R

report/correlation.html: data/klass-release-metrics.rds data/klass-metrics.rds script/correlation.R
	./run-script.rb script/correlation.R

data/fileloc.rds: raw-data/files.txt data/eclipse-releases.rds script/count-loc.R
	./run-script.rb script/count-loc.R

report/count-loc.html: raw-data/files.txt data/eclipse-releases.rds script/count-loc.R
	./run-script.rb script/count-loc.R

report/extra-bug-reports.html: data/bugs.rds data/commit-log.rds script/extra-bug-reports.R
	./run-script.rb script/extra-bug-reports.R

report/find-files.html: data/klasses.txt script/find-files.R
	./run-script.rb script/find-files.R

data/bugs.rds: data/changed-klasses.rds data/commit-log.rds script/map-bug-reports.R
	./run-script.rb script/map-bug-reports.R

report/map-bug-reports.html: data/changed-klasses.rds data/commit-log.rds script/map-bug-reports.R
	./run-script.rb script/map-bug-reports.R

data/changed-klasses.rds: data/changed-files.rds data/klasses.txt script/map-changed-classes.R
	./run-script.rb script/map-changed-classes.R

report/map-changed-classes.html: data/changed-files.rds data/klasses.txt script/map-changed-classes.R
	./run-script.rb script/map-changed-classes.R

data/klass-files.rds: raw-data/files.txt data/klasses.txt script/map-classes-to-files.R
	./run-script.rb script/map-classes-to-files.R

report/map-classes-to-files.html: raw-data/files.txt data/klasses.txt script/map-classes-to-files.R
	./run-script.rb script/map-classes-to-files.R

data/bugs-extended.rds: raw-data/extra-bugs-versions.grep data/bugs.rds script/parse-extra-bugs.R
	./run-script.rb script/parse-extra-bugs.R

report/parse-extra-bugs.html: raw-data/extra-bugs-versions.grep data/bugs.rds script/parse-extra-bugs.R
	./run-script.rb script/parse-extra-bugs.R

data/commit-log.rds:  script/parse-git-log.R
	./run-script.rb script/parse-git-log.R

data/changed-files.rds:  script/parse-git-log.R
	./run-script.rb script/parse-git-log.R

report/parse-git-log.html:  script/parse-git-log.R
	./run-script.rb script/parse-git-log.R

data/eclipse-releases.rds: data/eclipse-releases.csv script/parse-release-dates.R
	./run-script.rb script/parse-release-dates.R

report/parse-release-dates.html: data/eclipse-releases.csv script/parse-release-dates.R
	./run-script.rb script/parse-release-dates.R

data/violations.rds: raw-data/violfile.txt data/viol-klasses.tsv script/parse-violfile.R
	./run-script.rb script/parse-violfile.R

data/viol-releases.rds: raw-data/violfile.txt data/viol-klasses.tsv script/parse-violfile.R
	./run-script.rb script/parse-violfile.R

report/parse-violfile.html: raw-data/violfile.txt data/viol-klasses.tsv script/parse-violfile.R
	./run-script.rb script/parse-violfile.R

report/reopening.html: data/klass-release-metrics.rds data/klass-major-metrics.rds data/eclipse-releases.rds script/reopening.R
	./run-script.rb script/reopening.R

report/timeseries.html: data/klass-release-metrics.rds script/timeseries.R
	./run-script.rb script/timeseries.R

data/eclipse-releases.csv: raw-data/eclipse-releases-site.tsv script/convert-release-dates.rb
	./run-script.rb script/convert-release-dates.rb

data/violtypes.txt: raw-data/violfile.txt script/detect-viol-types.rb
	./run-script.rb script/detect-viol-types.rb

data/viol-klasses.tsv: raw-data/violfile.txt script/parse-violmessage.rb
	./run-script.rb script/parse-violmessage.rb

data/klasses.txt: raw-data/violfile.txt script/parse-violmessage.rb
	./run-script.rb script/parse-violmessage.rb
