# frozen_string_literal: true

require "rake/testtask"
require "cucumber/rake/task"

require "rexml/document"
require "rexml/streamlistener"

# Listener class used to process GIR xml data, for creating test stubs.
class Listener
  include REXML::StreamListener

  def initialize
    @class_stack = []
    @stack = []
    @skip_state = []
  end

  attr_accessor :result, :namespace

  def tag_start(tag, attrs)
    @stack.push [tag, attrs]
    if @skip_state.last || skippable?(attrs)
      @skip_state.push true
      return
    else
      @skip_state.push false
    end

    obj_name = attrs["name"]
    case tag
    when "constant"
      start_constant(obj_name)
    when "record", "class", "enumeration", "bitfield", "interface", "union"
      start_object(tag, obj_name)
    when "constructor"
      start_constructor(obj_name)
    when "field"
      start_field(obj_name, attrs)
    when "function", "method"
      start_function(tag, obj_name)
    when "member"
      start_member(obj_name)
    when "namespace"
      start_namespace(obj_name)
    when "property"
      start_property(obj_name, attrs)
    when "glib:signal"
      start_signal(obj_name)
    when "type", "alias", "return-value", "parameters",
      "instance-parameter", "parameter", "doc", "array",
      "repository", "include", "package", "source-position",
      "implements", "prerequisite", "attribute",
      "docsection", "doc-version", "doc-deprecated", "doc-stability",
      "virtual-method", "callback"
      # Not printed
    else
      puts "Skipping #{tag}: #{attrs}"
    end
  end

  def tag_end(tag)
    orig_tag, = *@stack.pop
    skipping = @skip_state.pop
    raise "Expected #{orig_tag}, got #{tag}" if orig_tag != tag
    return if skipping

    case tag
    when "constant"
      end_constant
    when "record", "class", "enumeration", "bitfield", "interface", "union"
      end_object
    when "function", "method", "constructor", "member", "property", "glib:signal"
      end_functionish
    when "field"
      end_field
    when "namespace"
      end_namespace
    end
  end

  private

  def start_constant(obj_name)
    result.puts "  it \"has the constant #{obj_name}\" do"
  end

  def start_object(tag, obj_name)
    result.puts "  describe \"#{namespace}::#{obj_name}\" do" unless @class_stack.any?
    @class_stack << [tag, obj_name]
  end

  def start_constructor(obj_name)
    result.puts "    it \"creates an instance using ##{obj_name}\" do"
  end

  def start_field(obj_name, attrs)
    return if current_object_type == "class"

    if attrs["private"] == "1"
      result.puts "    it \"has a private field #{obj_name}\" do"
    elsif attrs["writable"] == "1"
      result.puts "    it \"has a writable field #{obj_name}\" do"
    else
      result.puts "    it \"has a read-only field #{obj_name}\" do"
    end
  end

  def start_function(tag, obj_name)
    spaces = @class_stack.any? ? "  " : ""
    result.puts "  #{spaces}it \"has a working #{tag} ##{obj_name}\" do"
  end

  def start_member(obj_name)
    result.puts "    it \"has the member :#{obj_name}\" do"
  end

  def start_namespace(obj_name)
    result.puts "describe #{obj_name} do"
  end

  def start_property(obj_name, attrs)
    accessor_name = obj_name.tr("-", "_")

    result.puts "    describe \"its '#{obj_name}' property\" do"
    result.puts "      it \"can be retrieved with #get_property\" do"
    result.puts "      end"
    result.puts "      it \"can be retrieved with ##{accessor_name}\" do"
    result.puts "      end"

    return if attrs["writable"] != "1"

    result.puts "      it \"can be set with #set_property\" do"
    result.puts "      end"
    result.puts "      it \"can be set with ##{accessor_name}=\" do"
    result.puts "      end"
  end

  def start_signal(obj_name)
    result.puts "    it \"handles the '#{obj_name}' signal\" do"
  end

  def end_constant
    result.puts "  end"
  end

  def end_object
    @class_stack.pop
    result.puts "  end" unless @class_stack.any?
  end

  def end_functionish
    if @class_stack.any?
      result.puts "    end"
    else
      result.puts "  end"
    end
  end

  def end_field
    result.puts "    end" if current_object_type != "class"
  end

  def end_namespace
    result.puts "end"
  end

  def skippable?(attrs)
    return true if attrs["disguised"] == "1"
    return true if attrs["introspectable"] == "0"
    return true if attrs["glib:is-gtype-struct-for"]

    false
  end

  def current_object_type
    @class_stack.last&.first
  end

  def current_object_name
    @class_stack.last&.last
  end
end

namespace :test do
  def define_test_task(name)
    Rake::TestTask.new(name) do |t|
      t.libs = ["lib"]
      t.ruby_opts += ["-w -Itest"]
      yield t
    end
  end

  define_test_task(:base) do |t|
    t.test_files = FileList["test/gir_ffi-base/**/*_test.rb"]
  end

  define_test_task(:introspection) do |t|
    t.test_files = FileList["test/ffi-gobject_introspection/**/*_test.rb"]
  end

  define_test_task(:main) do |t|
    t.test_files = FileList["test/gir_ffi/**/*_test.rb"]
  end

  define_test_task(:overrides) do |t|
    t.test_files = FileList["test/ffi-gobject_test.rb",
                            "test/ffi-glib/**/*_test.rb",
                            "test/ffi-gobject/**/*_test.rb"]
  end

  define_test_task(:integration) do |t|
    t.test_files = FileList["test/integration/**/*_test.rb"]
  end

  desc "Build test libraries and typelibs"
  task lib: "test/lib/Makefile" do
    sh %(cd test/lib && make)
  end

  task introspection: :lib
  task main: :lib
  task overrides: :lib
  task integration: :lib

  desc "Run the entire test suite as one with simplecov activated"
  define_test_task(:all) do |t|
    t.test_files = FileList["test/**/*_test.rb"]
    t.ruby_opts += ["-rbundler/setup -rsimplecov -w -Itest"]
  end

  task all: :lib

  desc "Run all individual test suites separately"
  task suites: [:base,
                :introspection,
                :main,
                :overrides,
                :integration]

  def make_stub_file(libname)
    file = File.new "test/lib/#{libname}-1.0.gir"
    listener = Listener.new
    listener.result = File.open("tmp/#{libname.downcase}_lines.rb", "w")
    listener.namespace = libname
    REXML::Document.parse_stream file, listener
  end

  desc "Create stubs for integration tests"
  task stub: :lib do
    make_stub_file "Everything"
    make_stub_file "GIMarshallingTests"
    make_stub_file "Regress"
    make_stub_file "Utility"
    make_stub_file "WarnLib"
  end

  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
  end
end

file "test/lib/Makefile" => "test/lib/configure" do
  sh %(cd test/lib && ./configure --enable-maintainer-mode)
end

file "test/lib/configure" => ["test/lib/autogen.sh", "test/lib/configure.ac"] do
  sh %(cd test/lib && ./autogen.sh)
end

task test: "test:all"
