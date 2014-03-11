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

<pre>
|-- report/
|-- script/
|-- lib/
|-- data/
|-- raw-data/
|-- doc/
|-- config/
</pre>

#### [report/](https://github.com/rodrigorgs/arch-violations-bugs/tree/master/report)

Reports created by scripts.

#### [script/](https://github.com/rodrigorgs/arch-violations-bugs/tree/master/script)

Scripts to transform data and create reports.

#### [lib/](https://github.com/rodrigorgs/arch-violations-bugs/tree/master/lib)

Reusable functions.

#### [data/](https://github.com/rodrigorgs/arch-violations-bugs/tree/master/data)

Data created by scripts from raw data.

#### [raw-data/](https://github.com/rodrigorgs/arch-violations-bugs/tree/master/raw-data)

Raw data, manually created.

#### [doc/](https://github.com/rodrigorgs/arch-violations-bugs/tree/master/doc)

Developer documentation (data and processing pipeline).

#### [config/](https://github.com/rodrigorgs/arch-violations-bugs/tree/master/config)

Configuration files.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -m "Add some feature"`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request  :)

English is the universal language nowadays, so please don't create or comment on issues using another language.

## History

For detailed changelog, see [Releases](https://github.com/rodrigorgs/arch-violations-bugs/releases).

## Authors

[![João Arthur](http://gravatar.com/avatar/3213574af4788324b104dbc02e9ded9c?s=70)](https://github.com/joaoarthurbm) | [![Rodrigo Souza](http://gravatar.com/avatar/5b5d74b9ee9cd59f57c33dcee63517fa?s=70)](https://github.com/rodrigorgs)
--- | --- | --- | --- | --- | --- | ---
[João Arthur](https://github.com/joaoarthurbm)<br>joaoarthurbm@gmail.com | [Rodrigo Souza](https://github.com/rodrigorgs)<br>rodrigorgs@gmail.com |

