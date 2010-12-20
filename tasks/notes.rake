# The following code is copied straight from Bones 2.5.1
#

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
  def self.enumerate tag, id = nil, opts = {}
    extractor = new(tag, id)
    extractor.display(extractor.find, opts)
  end

  attr_reader :tag, :id

  # Creates a new annotation extractor configured to use the _project_ open
  # strcut and to search for the given _tag_ (which can be more than one tag
  # via a regular expression 'or' operation -- i.e. THIS|THAT|OTHER)
  #
  def initialize tag, id
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

    files = Dir.glob("lib/**/*.rb")
    files += Dir.glob("test/**/*.rb")
    files.each do |fn|
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

note_tags = ["TODO", "FIXME", "OPTIMIZE"]

desc "Enumerate all annotations"
task :notes do |t|
  id = if t.application.top_level_tasks.length > 1
    t.application.top_level_tasks.slice!(1..-1).join(' ')
  end
  Bones::AnnotationExtractor.enumerate(
      note_tags.join('|'), id, :tag => true)
end

namespace :notes do
  note_tags.each do |tag|
    desc "Enumerate all #{tag} annotations"
    task tag.downcase.to_sym do |t|
      id = if t.application.top_level_tasks.length > 1
        t.application.top_level_tasks.slice!(1..-1).join(' ')
      end
      Bones::AnnotationExtractor.enumerate(tag, id)
    end
  end
end
