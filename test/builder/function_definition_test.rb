require File.expand_path('../test_helper.rb', File.dirname(__FILE__))
require 'girffi/builder/function_definition'

class FunctionDefinitionTest < Test::Unit::TestCase
  context "The FunctionDefinition builder" do
    setup do
      @builder = GirFFI::Builder.new
    end

    should "build correct definition of Gtk.init" do
      go = @builder.function_introspection_data 'Gtk', 'init'
      fbuilder = GirFFI::Builder::FunctionDefinition.new go
      code = fbuilder.generate

      expected = "
	def init argc, argv
	  _v1 = GirFFI::Helper::Arg.int_to_inoutptr argc
	  _v3 = GirFFI::Helper::Arg.string_array_to_inoutptr argv
	  Lib.gtk_init _v1, _v3
	  _v2 = GirFFI::Helper::Arg.outptr_to_int _v1
	  _v4 = GirFFI::Helper::Arg.outptr_to_string_array _v3, argv.nil? ? 0 : argv.size
	  return _v2, _v4
	end
      "

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Gtk::Widget.show" do
      go = @builder.method_introspection_data 'Gtk', 'Widget', 'show'
      fbuilder = GirFFI::Builder::FunctionDefinition.new go
      code = fbuilder.generate

      expected = "
	def show
	  Lib.gtk_widget_show @gobj
	end
      "

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of GObject.signal_connect_data" do
      go = @builder.function_introspection_data 'GObject', 'signal_connect_data'
      fbuilder = GirFFI::Builder::FunctionDefinition.new go
      code = fbuilder.generate

      expected = "
	def signal_connect_data instance, detailed_signal, data, destroy_data, connect_flags, &c_handler
	  _v1 = GirFFI::Helper::Arg.object_to_inptr instance
	  _v2 = c_handler.to_proc
	  Lib::CALLBACKS << _v2
	  _v3 = GirFFI::Helper::Arg.object_to_inptr data
	  Lib.g_signal_connect_data _v1, detailed_signal, _v2, _v3, destroy_data, connect_flags
	end
      "

      assert_equal cws(expected), cws(code)
    end
  end
end
