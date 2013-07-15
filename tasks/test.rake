require 'rake/testtask'

require 'rexml/document'
require 'rexml/streamlistener'

# Listener class used to process GIR xml data, for creating test stubs.
class Listener
  include REXML::StreamListener

  def initialize
    @inside_class = false
  end

  attr_accessor :result
  attr_accessor :namespace

  def tag_start name, attrs
    return if attrs['disguised'] == '1'
    return if attrs['introspectable'] == '0'
    return if attrs['glib:is-gtype-struct-for']

    obj_name = attrs['name']
    case name
    when "constant"
      result.puts "  it \"has the constant #{obj_name}\" do"
    when "record", "class", "enumeration", "bitfield", "interface", "union"
      result.puts "  describe \"#{namespace}::#{obj_name}\" do"
      @inside_class = true
    when "constructor"
      result.puts "    it \"creates an instance using ##{obj_name}\" do"
    when "function", "method"
      spaces = @inside_class ? "  " : ""
      result.puts "  #{spaces}it \"has a working #{name} ##{obj_name}\" do"
    when "member"
      result.puts "    it \"has the member :#{obj_name}\" do"
    when "type", "return-value", "parameters", "parameter", "doc", "array"
    else
      puts "Skipping #{name}"
    end
  end

  def tag_end name
    case name
    when "record", "class", "enumeration", "bitfield", "interface", "union"
      @inside_class = false
    end
  end
end

namespace :test do
  def define_test_task name
    Rake::TestTask.new(name) do |t|
      t.libs = ['lib']
      t.ruby_opts += ["-w -Itest"]
      yield t
    end
  end

  define_test_task(:base) do |t|
    t.test_files = FileList['test/gir_ffi-base/**/*_test.rb']
  end

  define_test_task(:introspection) do |t|
    t.test_files = FileList['test/ffi-gobject_introspection/**/*_test.rb']
  end

  define_test_task(:main) do |t|
    t.test_files = FileList['test/gir_ffi_test.rb',
                            'test/gir_ffi/**/*_test.rb']
  end

  define_test_task(:overrides) do |t|
    t.test_files = FileList['test/ffi-gobject_test.rb',
                            'test/ffi-glib/**/*_test.rb',
                            'test/ffi-gobject/**/*_test.rb']
  end

  define_test_task(:integration) do |t|
    t.test_files = FileList['test/integration/**/*_test.rb']
  end

  desc 'Build Regress test library and typelib'
  task :lib => "test/lib/Makefile" do
    sh %{cd test/lib && make}
  end

  task :introspection => :lib
  task :main => :lib
  task :overrides => :lib
  task :integration => :lib

  desc 'Run the entire test suite as one'
  define_test_task(:all) do |t|
    t.test_files = FileList['test/**/*_test.rb']
  end

  task :all => :lib

  desc 'Run all individual test suites separately'
  task :suites => [:base,
                   :introspection,
                   :main,
                   :overrides,
                   :integration]

  desc "Create stubs for Regress and GIMarshallingTests tests"
  task :stub => :lib do
    file = File.new 'test/lib/Regress-1.0.gir'
    listener = Listener.new
    listener.result = File.open('tmp/regress_lines.rb', 'w')
    listener.namespace = "Regress"
    REXML::Document.parse_stream file, listener

    file = File.new 'test/lib/GIMarshallingTests-1.0.gir'
    listener = Listener.new
    listener.result = File.open('tmp/gimarshallingtests_lines.rb', 'w')
    listener.namespace = "GIMarshallingTests"
    REXML::Document.parse_stream file, listener
  end
end

file "test/lib/Makefile" => "test/lib/configure" do
  sh %{cd test/lib && ./configure --enable-maintainer-mode}
end

file "test/lib/configure" do
  sh %{cd test/lib && NOCONFIGURE=1 ./autogen.sh}
end
