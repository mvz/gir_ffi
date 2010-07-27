# The following code is copied straight from Bones 2.5.1
#

begin
  require 'facets/ansicode'
  HAVE_COLOR = true
rescue LoadError
  HAVE_COLOR = false
end

module Bones

# A helper class used to find and display any annotations in a collection of
# project files.
#
class AnnotationExtractor

  class Annotation < Struct.new(:line, :tag, :text)
    # Returns a string representation of the annotation. If the
    # <tt>:tag</tt> parameter is given as +true+, then the annotation tag
    # will be included in the string.
    #
    def to_s( opts = {} )
      s = "[%3d] " % line
      s << "[#{tag}] " if opts[:tag]
      s << text
    end
  end

  # Enumerate all the annoations for the given _project_ and _tag_. This
  # will search for all athe annotations and display them on standard
  # output.
  #
  def self.enumerate( project, tag, id = nil, opts = {} )
    extractor = new(project, tag, id)
    extractor.display(extractor.find, opts)
  end

  attr_reader :tag, :project, :id

  # Creates a new annotation extractor configured to use the _project_ open
  # strcut and to search for the given _tag_ (which can be more than one tag
  # via a regular expression 'or' operation -- i.e. THIS|THAT|OTHER)
  #
  def initialize( project, tag, id) 
    @project = project
    @tag = tag
    @id = @id_rgxp = nil

    unless id.nil? or id.empty?
      @id = id
      @id_rgxp = Regexp.new(Regexp.escape(id), Regexp::IGNORECASE)
    end
  end

  # Iterate over all the files in the project and extract annotations from
  # the those files. Returns the results as a hash for display.
  #
  def find
    results = {}
    rgxp = %r/(#{tag}):?\s*(.*?)(?:\s*(?:-?%>|\*+\/))?$/o

    extensions = project.notes.extensions.dup
    exclude = if project.notes.exclude.empty? then nil
              else Regexp.new(project.notes.exclude.join('|')) end

    project.gem.files.each do |fn|
      next if exclude && exclude =~ fn
      next unless extensions.include? File.extname(fn)
      results.update(extract_annotations_from(fn, rgxp))
    end

    results
  end

  # Extract any annotations from the given _file_ using the regular
  # expression _pattern_ provided.
  #
  def extract_annotations_from( file, pattern )
    lineno = 0
    result = File.readlines(file).inject([]) do |list, line|
      lineno += 1
      next list unless m = pattern.match(line)
      next list << Annotation.new(lineno, m[1], m[2]) unless id

      text = m[2]
      if text =~ @id_rgxp
        text.gsub!(@id_rgxp) {|str| ANSICode.green(str)} if HAVE_COLOR
        list << Annotation.new(lineno, m[1], text)
      end
      list
    end
    result.empty? ? {} : { file => result }
  end

  # Print the results of the annotation extraction to the screen. If the
  # <tt>:tags</tt> option is set to +true+, then the annotation tag will be
  # displayed.
  #
  def display( results, opts = {} )
    results.keys.sort.each do |file|
      puts "#{file}:"
      results[file].each do |note|
        puts "  * #{note.to_s(opts)}"
      end
      puts
    end
  end

end  # class AnnotationExtractor
end  # module Bones

desc "Enumerate all annotations"
task :notes do |t|
  id = if t.application.top_level_tasks.length > 1
    t.application.top_level_tasks.slice!(1..-1).join(' ')
  end
  Bones::AnnotationExtractor.enumerate(
      PROJ, PROJ.notes.tags.join('|'), id, :tag => true)
end

namespace :notes do
  PROJ.notes.tags.each do |tag|
    desc "Enumerate all #{tag} annotations"
    task tag.downcase.to_sym do |t|
      id = if t.application.top_level_tasks.length > 1
        t.application.top_level_tasks.slice!(1..-1).join(' ')
      end
      Bones::AnnotationExtractor.enumerate(PROJ, tag, id)
    end
  end
end

# EOF
