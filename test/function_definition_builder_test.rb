require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'girffi/builder'
require 'girffi/function_definition_builder'

class FunctionDefinitionBuilderTest < Test::Unit::TestCase
  context "The FunctionDefinition builder" do
    should "build correct definition of Gtk.init" do
      go = get_function_introspection_data 'Gtk', 'init'
      fbuilder = GirFFI::FunctionDefinitionBuilder.new go, Lib
      code = fbuilder.generate

      expected = "
	def init argc, argv
	  _v1 = GirFFI::ArgHelper.int_to_inoutptr argc
	  _v3 = GirFFI::ArgHelper.string_array_to_inoutptr argv
	  Lib.gtk_init _v1, _v3
	  _v2 = GirFFI::ArgHelper.outptr_to_int _v1
	  _v4 = GirFFI::ArgHelper.outptr_to_string_array _v3, argv.nil? ? 0 : argv.size
	  return _v2, _v4
	end
      "

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Gtk::Widget.show" do
      go = get_method_introspection_data 'Gtk', 'Widget', 'show'
      fbuilder = GirFFI::FunctionDefinitionBuilder.new go, Lib
      code = fbuilder.generate

      expected = "
	def show
	  Lib.gtk_widget_show @gobj
	end
      "

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of GObject.signal_connect_data" do
      go = get_function_introspection_data 'GObject', 'signal_connect_data'
      fbuilder = GirFFI::FunctionDefinitionBuilder.new go, Lib
      code = fbuilder.generate

      expected =
	"def signal_connect_data instance, detailed_signal, c_handler, data, destroy_data, connect_flags
	  _v1 = GirFFI::ArgHelper.object_to_inptr instance
	  _v2 = GirFFI::ArgHelper.mapped_callback_args c_handler
	  Lib::CALLBACKS << _v2
	  _v3 = GirFFI::ArgHelper.object_to_inptr data
	  _v4 = GirFFI::ArgHelper.mapped_callback_args destroy_data
	  Lib::CALLBACKS << _v4
	  Lib.g_signal_connect_data _v1, detailed_signal, _v2, _v3, _v4, connect_flags
	end"

      assert_equal cws(expected), cws(code)
    end
  end
end
