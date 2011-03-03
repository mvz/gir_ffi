require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class ModuleBuilderTest < Test::Unit::TestCase
  context "The Builder::Module object" do
    context "for Gtk" do
      setup do
	@mbuilder = GirFFI::Builder::Module.new('Gtk')
      end

      context "looking at Gtk.main" do
	setup do
	  @go = get_function_introspection_data 'Gtk', 'main'
	end

	should "build correct definition of Gtk.main" do
	  code = @mbuilder.send :function_definition, @go, Lib
	  expected = "def main\n::Lib.gtk_main\nend"
	  assert_equal cws(expected), cws(code)
	end
      end

      context "looking at Gtk.init" do
	setup do
	  @go = get_function_introspection_data 'Gtk', 'init'
	end

	should "delegate definition to Builder::Function" do
	  code = @mbuilder.send :function_definition, @go, Lib
	  expected = GirFFI::Builder::Function.new(@go, Lib).generate
	  assert_equal cws(expected), cws(code)
	end
      end
    end

    context "for GObject" do
      setup do
	@mbuilder = GirFFI::Builder::Module.new('GObject')
      end

      context "looking at GObject.signal_connect_data" do
	setup do
	  @go = get_function_introspection_data 'GObject', 'signal_connect_data'
	end

	should "delegate definition to Builder::Function" do
	  code = @mbuilder.send :function_definition, @go, Lib
	  expected = GirFFI::Builder::Function.new(@go, Lib).generate
	  assert_equal cws(expected), cws(code)
	end
      end
    end
  end
end
