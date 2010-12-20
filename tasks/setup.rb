
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'ostruct'
require 'find'

# TODO: Clean up bones' task set to remove unwanted parts.

PROJ = OpenStruct.new(
  # Project Defaults
  :name => nil,
  :summary => nil,
  :description => nil,
  :changes => nil,
  :authors => nil,
  :email => nil,
  :url => "\000",
  :version => ENV['VERSION'] || '0.0.0',
  :exclude => %w(tmp$ bak$ ~$ CVS \.svn/ \.git/ ^pkg/),
  :release_name => ENV['RELEASE'],

  # System Defaults
  :ruby_opts => %w(-w),
  :libs => [],
  :history_file => 'History.txt',
  :readme_file => 'README.txt',
  :ignore_file => '.bnsignore',

  # File Annotations
  :notes => OpenStruct.new(
    :exclude => %w(^tasks/setup\.rb$),
    :extensions => %w(.txt .rb .erb .rdoc) << '',
    :tags => %w(FIXME OPTIMIZE TODO)
  )

)

# Load the other rake files in the tasks folder
tasks_dir = File.expand_path(File.dirname(__FILE__))
rakefiles = Dir.glob(File.join(tasks_dir, '*.rake')).sort
import(*rakefiles)

# Setup the project libraries
%w(lib ext).each {|dir| PROJ.libs << dir if test ?d, dir}

# Scans the current working directory and creates a list of files that are
# candidates to be in the manifest.
#
def manifest
  files = []
  exclude = PROJ.exclude.dup
  comment = %r/^\s*#/
 
  # process the ignore file and add the items there to the exclude list
  if test(?f, PROJ.ignore_file)
    ary = []
    File.readlines(PROJ.ignore_file).each do |line|
      next if line =~ comment
      line.chomp!
      line.strip!
      next if line.nil? or line.empty?

      glob = line =~ %r/\*\./ ? File.join('**', line) : line
      Dir.glob(glob).each {|fn| ary << "^#{Regexp.escape(fn)}"}
    end
    exclude.concat ary
  end

  # generate a regular expression from the exclude list
  exclude = Regexp.new(exclude.join('|'))

  Find.find '.' do |path|
    path.sub! %r/^(\.\/|\/)/o, ''
    next unless test ?f, path
    next if path =~ exclude
    files << path
  end
  files.sort!
end

# EOF
