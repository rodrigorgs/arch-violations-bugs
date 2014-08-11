#!/usr/bin/env ruby

require 'fileutils'

def create_notebook(path)
  dir = File.dirname(path)
  filename = File.basename(path)
  filename_no_ext = File.basename(filename, ".*")

  oldpwd = FileUtils.pwd
  FileUtils.chdir(dir)

  system %Q[Rscript -e "library(knitr); knitr::spin('#{filename}'); library(markdown); markdownToHTML('#{filename_no_ext}.md', '#{filename_no_ext}.html')"]

  FileUtils.rm "#{filename_no_ext}.md" if File.exist?("#{filename_no_ext}.md")
  FileUtils.mv "#{filename_no_ext}.html", '../report' if File.exist?("#{filename_no_ext}.html") && File.directory?("../report")

  # # Fix rCharts bug
  # sed -i ".bak" -e 's/\\\\n/\\n/g' figure/*.html
  # rm figure/*.bak

  FileUtils.chdir(oldpwd)
end

def execute_script(basename, script_dir)
  if basename =~ /\.[Rr]$/
    create_notebook basename
  elsif basename =~ /\.rb$/
    txt = basename.gsub(/\.rb$/, '.txt')
    system "ruby #{basename} > ../report/#{txt}"
  end
end

def force_run(path)
  basename = File.basename(path)
  dirname = File.dirname(path)
  script_dir = File.expand_path(File.dirname(__FILE__))
  pwd = FileUtils.pwd
  
  FileUtils.chdir(dirname)
  puts "*** Running script #{basename}..."
  begin
    execute_script(basename, script_dir)
  ensure
    FileUtils.chdir(pwd)
  end
end

if __FILE__ == $0
  path = ARGV[0]
  force_run(path)
end
