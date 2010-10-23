
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
  ),

  # Test::Unit
  :test => OpenStruct.new(
    :files => FileList['test/**/*_test.rb'],
    :file  => 'test/all.rb',
    :opts  => []
  )
)

# Load the other rake files in the tasks folder
tasks_dir = File.expand_path(File.dirname(__FILE__))
post_load_fn = File.join(tasks_dir, 'post_load.rake')
rakefiles = Dir.glob(File.join(tasks_dir, '*.rake')).sort
rakefiles.unshift(rakefiles.delete(post_load_fn)).compact!
import(*rakefiles)

# Setup the project libraries
%w(lib ext).each {|dir| PROJ.libs << dir if test ?d, dir}

%w(facets/ansicode).each do |lib|
  begin
    require lib
    Object.instance_eval {const_set "HAVE_#{lib.tr('/','_').upcase}", true}
  rescue LoadError
    Object.instance_eval {const_set "HAVE_#{lib.tr('/','_').upcase}", false}
  end
end

# Reads a file at +path+ and spits out an array of the +paragraphs+
# specified.
#
#    changes = paragraphs_of('History.txt', 0..1).join("\n\n")
#    summary, *description = paragraphs_of('README.txt', 3, 3..8)
#
def paragraphs_of( path, *paragraphs )
  title = String === paragraphs.first ? paragraphs.shift : nil
  ary = File.read(path).delete("\r").split(/\n\n+/)

  result = if title
    tmp, matching = [], false
    rgxp = %r/^=+\s*#{Regexp.escape(title)}/i
    paragraphs << (0..-1) if paragraphs.empty?

    ary.each do |val|
      if val =~ rgxp
        break if matching
        matching = true
        rgxp = %r/^=+/i
      elsif matching
        tmp << val
      end
    end
    tmp
  else ary end

  result.values_at(*paragraphs)
end

# Adds the given arguments to the include path if they are not already there
#
def ensure_in_path( *args )
  args.each do |path|
    path = File.expand_path(path)
    $:.unshift(path) if test(?d, path) and not $:.include?(path)
  end
end

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
