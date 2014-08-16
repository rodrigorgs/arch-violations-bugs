#!/usr/bin/env ruby

require 'fileutils'
require 'set'
require 'date'

# TODO: discard comments from source code, so we ignore changes to comments. See https://code.google.com/p/java-comment-preprocessor/

#
# Changeset: modifications to a specific file in a specific revision.
#
# Includes:
#
# * the lines that were deleted in this changeset
# * the creation date of the bug fixed by the changeset
# * previous commits that added lines that were deleted in this changeset
#   (only commits before the bug creation date)
#
class Changeset
  attr_accessor :file, :rev, :bug_creation, :lines, :inducing_changes

  def initialize(hash)
    @file = hash[:file]
    @rev = hash[:rev]
    @bug_creation = hash[:bug_creation]
    @lines = []
    @inducing_changes = Set.new
  end
end

def deleted_lines_from_diff_fragment(diff)
  lines = []
  diff.scan(/@@ -(\d+)(,\d+)? /) do
    initial_line = $1.to_i
    num_lines = ($2 || ",1")[1..-1].to_i
    lines += num_lines.times.map { |i| initial_line + i }
  end
  lines
end

def deleted_lines_from_output(out, rev, bug_creation)
  changes = []
  out.scan(/--- a\/(.+?)\n(.+?)(?:\Z|^diff)/mi) do
    filename = $1
    diff = $2
    
    change = Changeset.new(file: filename, rev: rev, bug_creation: bug_creation)
    change.lines = deleted_lines_from_diff_fragment(diff)
    changes << change
  end
  changes
end

def output_from_command(cmd)
  STDERR.puts cmd
  `#{cmd}`
end

def show_help_and_exit
  puts "Params: path-to-git-repo [input_file]"
  puts
  puts 'Input file format. Each line should have the following format:'
  puts
  puts 'hash,date'
  puts
  puts 'where hash is the commit hash, and date is creation date of the bug fixed by the commit'
  puts
  puts 'Output:'
  puts
  puts 'commit,inducing-commit'
  puts
  puts 'Where inducing-commit is a commit that added a line to a file that was removed in commit.'
  puts
  exit 1
end

if __FILE__ == $0

  if ARGV.size < 1
    show_help_and_exit
  end

  gitrepo_path = ARGV.shift

  input = ARGF.read.split("\n").map { |l| l.chomp.split(',') }

  puts "commit,inducing"
  FileUtils.chdir gitrepo_path
  input.each do |input_data|
    rev = input_data[0]
    bug_creation = DateTime.parse(input_data[1])

    out = output_from_command("git diff -U0 #{rev}^..#{rev}")
    if (out.empty?)
      STDERR.puts "No output for commit #{rev}. Skipping..."
      next
    end

    changes = deleted_lines_from_output(out, rev, bug_creation)

    # select only lines specified in changes.lines
    # select only lines representing commits that occurred before the bug was reported
    # the remaining lines represent bug introcuding commits
    changes.each do |change|
      # -l: long rev
      # -w: ignore whitespace
      # -M: detect moved or copied lines within a file
      # -C: detect moved or copied lines from other files
      # -c: Use the same output mode as git-annotate

      out = output_from_command(%Q[git blame --date=iso8601 -clwMC #{rev}^ -- "#{change.file}"])
      STDERR.puts "from #{gitrepo_path}"
      STDERR.puts out
      if (out.empty?)
        STDERR.puts "No output for commit #{rev} (blame). Skipping..."
        next
      end

      lines = out.split("\n")

      lines = change.lines.map { |i| lines[i-1] }
      lines.each do |line|
        components = line.split("\t")
        hash = components[0].strip
        p hash
        date_str = components[2]
        date = DateTime.parse(date_str)

        if (date < bug_creation)
          change.inducing_changes << hash
        end
      end
    end

    changes.each do |change|
      change.inducing_changes.each do |inducing|
        puts "#{change.rev.strip},#{inducing.strip}"
      end      
    end

    # p changes
    # puts "\n-------------------------------\n\n"
  end

end
