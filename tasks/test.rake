require 'rake/testtask'

require 'rexml/document'
require 'rexml/streamlistener'

# Listener class used to process GIR xml data, for creating test stubs.
class Listener
  include REXML::StreamListener

  def initialize
    @inside_class = false
    @stack = []
    @skip_state = []
  end

  attr_accessor :result
  attr_accessor :namespace

  def tag_start name, attrs
    @stack.push [name, attrs]
    if @skip_state.last || skippable?(attrs)
      @skip_state.push true
      return
    else
      @skip_state.push false
    end

    obj_name = attrs['name']
    case name
    when "constant"
      result.puts "  it \"has the constant #{obj_name}\" do"
    when "record", "class", "enumeration", "bitfield", "interface", "union"
      result.puts "  describe \"#{namespace}::#{obj_name}\" do"
      @inside_class = name
    when "constructor"
      result.puts "    it \"creates an instance using ##{obj_name}\" do"
    when "field"
      if @inside_class != 'class'
        if attrs['private'] == "1"
          result.puts "    it \"has a private field #{obj_name}\" do"
        elsif attrs['writable'] == "1"
          result.puts "    it \"has a writable field #{obj_name}\" do"
        else
          result.puts "    it \"has a read-only field #{obj_name}\" do"
        end
      end
    when "function", "method"
      spaces = @inside_class ? "  " : ""
      result.puts "  #{spaces}it \"has a working #{name} ##{obj_name}\" do"
    when "member"
      result.puts "    it \"has the member :#{obj_name}\" do"
    when "namespace"
      result.puts "describe #{obj_name} do"
    when "property"
      accessor_name = obj_name.gsub(/-/, '_')
      result.puts "    describe \"its '#{obj_name}' property\" do"
      result.puts "      it \"can be retrieved with #get_property\" do"
      result.puts "      end"
      result.puts "      it \"can be retrieved with ##{accessor_name}\" do"
      result.puts "      end"
      if attrs['writable'] == '1'
        result.puts "      it \"can be set with #set_property\" do"
        result.puts "      end"
        result.puts "      it \"can be set with ##{accessor_name}=\" do"
        result.puts "      end"
      end
    when "glib:signal"
      result.puts "    it \"handles the '#{obj_name}' signal\" do"
    when "type", "alias", "return-value", "parameters",
      "instance-parameter", "parameter", "doc", "array",
      "repository", "include", "package"
      # Not printed"
    else
      puts "Skipping #{name}: #{attrs}"
    end
  end

  def tag_end name
    org_name, _ = *@stack.pop
    skipping = @skip_state.pop
    raise "Expected #{org_name}, got #{name}" if org_name != name
    return if skipping

    case name
    when "constant"
      result.puts "  end"
    when "record", "class", "enumeration", "bitfield",
      "interface", "union"
      result.puts "  end"
      @inside_class = false
    when "function", "method"
      if @inside_class
        result.puts "    end"
      else
        result.puts "  end"
      end
    when "constructor", "member", "property", "glib:signal"
      result.puts "    end"
    when "field"
      if @inside_class != 'class'
        result.puts "    end"
      end
    when "namespace"
      result.puts "end"
    end
  end

  def skippable? attrs
    return true if attrs['disguised'] == '1'
    return true if attrs['introspectable'] == '0'
    return true if attrs['glib:is-gtype-struct-for']
    false
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
