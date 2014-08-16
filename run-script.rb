#!/usr/bin/env ruby

require 'fileutils'

def create_notebook(path)
  dir = File.dirname(path)
  filename = File.basename(path)
  filename_no_ext = File.basename(filename, ".*")

  oldpwd = FileUtils.pwd
  FileUtils.chdir(dir)

  cmd = %Q[Rscript '#{filename}' | tee '../report/#{filename_no_ext}.html']
  puts cmd
  ret = system cmd

  # FileUtils.rm "#{filename_no_ext}.md" if File.exist?("#{filename_no_ext}.md")
  # FileUtils.mv "#{filename_no_ext}.html", '../report' if File.exist?("#{filename_no_ext}.html") && File.directory?("../report")

  # # Fix rCharts bugw
  # sed -i ".bak" -e 's/\\\\n/\\n/g' figure/*.html
  # rm figure/*.bak

  FileUtils.chdir(oldpwd)

  ret
end

def execute_script(basename, script_dir)
  ret = nil
  if basename =~ /\.[Rr]$/
    ret = create_notebook basename
  elsif basename =~ /\.rb$/
    txt = basename.gsub(/\.rb$/, '.txt')
    ret = system "ruby #{basename} > ../report/#{txt}"
  end
  ret
end

def force_run(path)
  ret = nil
  basename = File.basename(path)
  dirname = File.dirname(path)
  script_dir = File.expand_path(File.dirname(__FILE__))
  pwd = FileUtils.pwd
  
  FileUtils.chdir(dirname)
  puts "*** Running script #{basename}..."
  begin
    ret = execute_script(basename, script_dir)
  ensure
    FileUtils.chdir(pwd)
  end
end

if __FILE__ == $0
  path = ARGV[0]
  ret = force_run(path)
  exit ret ? 0 : 1
end
