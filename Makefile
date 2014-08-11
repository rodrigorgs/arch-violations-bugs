all: data/bugfix-commits.csv data/bugs-extended.rds data/bugs.rds data/changed-files.rds data/changed-klasses.rds data/commit-log.rds data/commits-with-releases.rds data/eclipse-releases.csv data/eclipse-releases.rds data/klass-files.rds data/klass-major-metrics.rds data/klass-metrics.rds data/klass-release-metrics.rds data/klasses.txt data/klassloc.rds data/metrics.rds data/viol-klasses.tsv data/viol-releases.rds data/violations.rds data/violtypes.txt raw-data/fileloc.rds raw-data/fix-inducing-commits.rds report/abc.html report/analyze-correlation-bugs.html report/analyze-target-hierviol.html report/build-metrics.html report/compute-klassloc.html report/correlation.html report/count-loc.html report/export-bugfix-commits.html report/extra-bug-reports.html report/find-all-bug-inducing-commits.html report/find-files.html report/map-bug-reports.html report/map-changed-classes.html report/map-classes-to-files.html report/map-commits-releases.html report/parse-extra-bugs.html report/parse-git-log.html report/parse-release-dates.html report/parse-violfile.html report/reopening.html report/timeseries.html

clean:
	rm -f data/bugfix-commits.csv data/bugs-extended.rds data/bugs.rds data/changed-files.rds data/changed-klasses.rds data/commit-log.rds data/commits-with-releases.rds data/eclipse-releases.csv data/eclipse-releases.rds data/klass-files.rds data/klass-major-metrics.rds data/klass-metrics.rds data/klass-release-metrics.rds data/klasses.txt data/klassloc.rds data/metrics.rds data/viol-klasses.tsv data/viol-releases.rds data/violations.rds data/violtypes.txt raw-data/fileloc.rds raw-data/fix-inducing-commits.rds report/abc.html report/analyze-correlation-bugs.html report/analyze-target-hierviol.html report/build-metrics.html report/compute-klassloc.html report/correlation.html report/count-loc.html report/export-bugfix-commits.html report/extra-bug-reports.html report/find-all-bug-inducing-commits.html report/find-files.html report/map-bug-reports.html report/map-changed-classes.html report/map-classes-to-files.html report/map-commits-releases.html report/parse-extra-bugs.html report/parse-git-log.html report/parse-release-dates.html report/parse-violfile.html report/reopening.html report/timeseries.html

report/abc.html: raw-data/fix-inducing-commits.rds data/bugfix-commits.csv data/commit-log.rds script/abc.R
	./run-script.rb script/abc.R

report/analyze-correlation-bugs.html: data/metrics.rds script/analyze-correlation-bugs.R
	./run-script.rb script/analyze-correlation-bugs.R

report/analyze-target-hierviol.html: data/commits-with-releases.rds data/changed-klasses.rds data/bugs-extended.rds data/metrics.rds script/analyze-target-hierviol.R
	./run-script.rb script/analyze-target-hierviol.R

data/metrics.rds: data/commits-with-releases.rds data/changed-klasses.rds data/eclipse-releases.rds data/violations.rds data/viol-releases.rds data/bugs-extended.rds data/klassloc.rds script/build-metrics.R
	./run-script.rb script/build-metrics.R

data/klass-release-metrics.rds: data/commits-with-releases.rds data/changed-klasses.rds data/eclipse-releases.rds data/violations.rds data/viol-releases.rds data/bugs-extended.rds data/klassloc.rds script/build-metrics.R
	./run-script.rb script/build-metrics.R

data/klass-major-metrics.rds: data/commits-with-releases.rds data/changed-klasses.rds data/eclipse-releases.rds data/violations.rds data/viol-releases.rds data/bugs-extended.rds data/klassloc.rds script/build-metrics.R
	./run-script.rb script/build-metrics.R

data/klass-metrics.rds: data/commits-with-releases.rds data/changed-klasses.rds data/eclipse-releases.rds data/violations.rds data/viol-releases.rds data/bugs-extended.rds data/klassloc.rds script/build-metrics.R
	./run-script.rb script/build-metrics.R

report/build-metrics.html: data/commits-with-releases.rds data/changed-klasses.rds data/eclipse-releases.rds data/violations.rds data/viol-releases.rds data/bugs-extended.rds data/klassloc.rds script/build-metrics.R
	./run-script.rb script/build-metrics.R

data/klassloc.rds: raw-data/fileloc.rds data/klass-files.rds script/compute-klassloc.R
	./run-script.rb script/compute-klassloc.R

report/compute-klassloc.html: raw-data/fileloc.rds data/klass-files.rds script/compute-klassloc.R
	./run-script.rb script/compute-klassloc.R

report/correlation.html: data/klass-release-metrics.rds data/klass-metrics.rds data/klass-metrics.rds script/correlation.R
	./run-script.rb script/correlation.R

raw-data/fileloc.rds: raw-data/files.txt data/eclipse-releases.rds script/count-loc.R
	./run-script.rb script/count-loc.R

report/count-loc.html: raw-data/files.txt data/eclipse-releases.rds script/count-loc.R
	./run-script.rb script/count-loc.R

data/bugfix-commits.csv: data/commit-log.rds data/bugs-extended.rds script/export-bugfix-commits.R
	./run-script.rb script/export-bugfix-commits.R

report/export-bugfix-commits.html: data/commit-log.rds data/bugs-extended.rds script/export-bugfix-commits.R
	./run-script.rb script/export-bugfix-commits.R

report/extra-bug-reports.html: data/bugs.rds data/commit-log.rds script/extra-bug-reports.R
	./run-script.rb script/extra-bug-reports.R

raw-data/fix-inducing-commits.rds: data/bugfix-commits.csv raw-data/gitrepos.csv script/find-all-bug-inducing-commits.R
	./run-script.rb script/find-all-bug-inducing-commits.R

report/find-all-bug-inducing-commits.html: data/bugfix-commits.csv raw-data/gitrepos.csv script/find-all-bug-inducing-commits.R
	./run-script.rb script/find-all-bug-inducing-commits.R

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

data/commits-with-releases.rds: data/commit-log.rds data/bugs-extended.rds data/eclipse-releases.rds script/map-commits-releases.R
	./run-script.rb script/map-commits-releases.R

report/map-commits-releases.html: data/commit-log.rds data/bugs-extended.rds data/eclipse-releases.rds script/map-commits-releases.R
	./run-script.rb script/map-commits-releases.R

data/bugs-extended.rds: raw-data/extra-bugs-reopened.grep raw-data/extra-bugs-versions.grep raw-data/extra-bugs-creation.grep data/bugs.rds script/parse-extra-bugs.R
	./run-script.rb script/parse-extra-bugs.R

report/parse-extra-bugs.html: raw-data/extra-bugs-reopened.grep raw-data/extra-bugs-versions.grep raw-data/extra-bugs-creation.grep data/bugs.rds script/parse-extra-bugs.R
	./run-script.rb script/parse-extra-bugs.R

data/commit-log.rds: raw-data/gitrepos.csv script/parse-git-log.R
	./run-script.rb script/parse-git-log.R

data/changed-files.rds: raw-data/gitrepos.csv script/parse-git-log.R
	./run-script.rb script/parse-git-log.R

report/parse-git-log.html: raw-data/gitrepos.csv script/parse-git-log.R
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
