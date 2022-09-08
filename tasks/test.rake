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

  HANDLED_TAGS = %w[
    constant record class enumeration bitfield interface union constructor
    field function method member namespace property
  ].freeze

  SILENT_TAGS = %w[
    type alias return-value parameters instance-parameter parameter doc array
    repository include package source-position implements prerequisite
    attribute docsection doc-version doc-deprecated doc-stability
    virtual-method callback
  ].freeze

  def tag_start(tag, attrs)
    push_state(tag, attrs)
    return if skipping?

    obj_name = attrs["name"]
    case tag
    when *HANDLED_TAGS
      send "start_#{tag}", tag, obj_name, attrs
    when "glib:signal"
      start_signal(tag, obj_name, attrs)
    when *SILENT_TAGS
      # Not printed
    else
      puts "Skipping #{tag}: #{attrs}"
    end
  end

  def tag_end(tag)
    orig_tag, skipping = pop_state
    raise "Expected #{orig_tag}, got #{tag}" if orig_tag != tag
    return if skipping

    case tag
    when *HANDLED_TAGS
      send "end_#{tag}"
    when "glib:signal"
      end_signal
    end
  end

  private

  def push_state(tag, attrs)
    @stack.push [tag, attrs]
    if @skip_state.last || skippable?(attrs)
      @skip_state.push true
    else
      @skip_state.push false
    end
  end

  def pop_state
    orig_tag, = *@stack.pop
    skipping = @skip_state.pop

    return orig_tag, skipping
  end

  def skipping?
    @skip_state.last
  end

  def start_constant(_tag, obj_name, _attrs)
    emit_indented 2, "it \"has the constant #{obj_name}\" do"
  end

  def start_class(tag, obj_name, attrs)
    emit_indented 2, "describe \"#{namespace}::#{obj_name}\" do" unless @class_stack.any?

    if attrs["glib:fundamental"] == "1"
      emit_indented 4, <<~RUBY
        it "does not have GObject::Object as an ancestor" do
        end
      RUBY
    end
    if attrs["abstract"] == "1"
      emit_indented 4, <<~RUBY
        it "cannot be instantiated" do
        end
      RUBY
    end
    @class_stack << [tag, obj_name]
  end

  def start_type(tag, obj_name, _attrs)
    emit_indented 2, "describe \"#{namespace}::#{obj_name}\" do" unless @class_stack.any?
    @class_stack << [tag, obj_name]
  end

  alias start_bitfield start_type
  alias start_enumeration start_type
  alias start_interface start_type
  alias start_record start_type
  alias start_union start_type

  def start_constructor(_tag, obj_name, _attrs)
    emit_indented 4, "it \"creates an instance using ##{obj_name}\" do"
  end

  def start_field(_tag, obj_name, attrs)
    return if current_object_type == "class"

    if attrs["private"] == "1"
      emit_indented 4, "it \"has a private field #{obj_name}\" do"
    elsif attrs["writable"] == "1"
      emit_indented 4, "it \"has a writable field #{obj_name}\" do"
    else
      emit_indented 4, "it \"has a read-only field #{obj_name}\" do"
    end
  end

  def start_function(tag, obj_name, _attrs)
    spaces = @class_stack.any? ? "  " : ""
    emit_indented 2, "#{spaces}it \"has a working #{tag} ##{obj_name}\" do"
  end

  alias start_method start_function

  def start_member(_tag, obj_name, _attrs)
    emit_indented 4, "it \"has the member :#{obj_name}\" do"
  end

  def start_namespace(_tag, obj_name, _attrs)
    emit_indented 0, "describe #{obj_name} do"
  end

  def start_property(_tag, obj_name, attrs)
    accessor_name = obj_name.tr("-", "_")

    emit_indented 4, "describe \"its '#{obj_name}' property\" do"

    can = attrs["readable"] == "0" ? "cannot" : "can"

    emit_indented 6, <<~RUBY
      it "#{can} be retrieved with #get_property" do
      end
      it "#{can} be retrieved with ##{accessor_name}" do
      end
    RUBY

    return if attrs["writable"] != "1"

    emit_indented 6, <<~RUBY
      it "can be set with #set_property" do
      end
      it "can be set with ##{accessor_name}=" do
      end
    RUBY
  end

  def start_signal(_tag, obj_name, _attrs)
    emit_indented 4, "it \"handles the '#{obj_name}' signal\" do"
  end

  def end_constant
    emit_indented 2, "end"
  end

  def end_object
    @class_stack.pop
    emit_indented 2, "end" unless @class_stack.any?
  end

  alias end_record end_object
  alias end_class end_object
  alias end_enumeration end_object
  alias end_bitfield end_object
  alias end_interface end_object
  alias end_union end_object

  def end_function
    if @class_stack.any?
      emit_indented 4, "end"
    else
      emit_indented 2, "end"
    end
  end

  alias end_constructor end_function
  alias end_method end_function
  alias end_member end_function
  alias end_property end_function
  alias end_signal end_function

  def end_field
    emit_indented 4, "end" if current_object_type != "class"
  end

  def end_namespace
    emit_indented 0, "end"
  end

  def emit_indented(indentation, string)
    prefix = " " * indentation
    string.split("\n").each do |line|
      result.puts "#{prefix}#{line}"
    end
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
    t.cucumber_opts = ["features", "--format pretty"]
  end
end

file "test/lib/Makefile" => "test/lib/configure" do
  sh %(cd test/lib && ./configure --enable-maintainer-mode)
end

file "test/lib/configure" => ["test/lib/autogen.sh", "test/lib/configure.ac"] do
  sh %(cd test/lib && ./autogen.sh)
end

task test: "test:all"
