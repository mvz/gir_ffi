require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

class ModuleBuilderTest < Test::Unit::TestCase
  context "The ModuleBuilder" do
    context "for Gtk" do
      setup do
	@mbuilder = GirFFI::ModuleBuilder.new('Gtk')
      end

      context "looking at Gtk.main" do
	setup do
	  @go = get_function_introspection_data 'Gtk', 'main'
	end

	should "build correct definition of Gtk.main" do
	  code = @mbuilder.send :function_definition, @go, Lib
	  expected = "def main\nLib.gtk_main\nend"
	  assert_equal cws(expected), cws(code)
	end
      end

      context "looking at Gtk.init" do
	setup do
	  @go = get_function_introspection_data 'Gtk', 'init'
	end

	should "delegate definition to FunctionDefinitionBuilder" do
	  code = @mbuilder.send :function_definition, @go, Lib
	  expected = GirFFI::FunctionDefinitionBuilder.new(@go, Lib).generate
	  assert_equal cws(expected), cws(code)
	end
      end
    end

    context "for GObject" do
      setup do
	@mbuilder = GirFFI::ModuleBuilder.new('GObject')
      end

      context "looking at GObject.signal_connect_data" do
	setup do
	  @go = get_function_introspection_data 'GObject', 'signal_connect_data'
	end

	should "delegate definition to FunctionDefinitionBuilder" do
	  code = @mbuilder.send :function_definition, @go, Lib
	  expected = GirFFI::FunctionDefinitionBuilder.new(@go, Lib).generate
	  assert_equal cws(expected), cws(code)
	end
      end
    end
  end
end
