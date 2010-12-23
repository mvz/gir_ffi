require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

class FunctionDefinitionBuilderTest < Test::Unit::TestCase
  context "The FunctionDefinition builder" do
    should "build correct definition of Gtk.init" do
      go = get_function_introspection_data 'Gtk', 'init'
      fbuilder = GirFFI::FunctionDefinitionBuilder.new go, Lib
      code = fbuilder.generate

      expected = "
	def init argv
	  argc = argv.length
	  _v1 = GirFFI::ArgHelper.int_to_inoutptr argc
	  _v3 = GirFFI::ArgHelper.utf8_array_to_inoutptr argv
	  ::Lib.gtk_init _v1, _v3
	  _v2 = GirFFI::ArgHelper.outptr_to_int _v1
	  _v4 = GirFFI::ArgHelper.outptr_to_utf8_array _v3, _v2
	  return _v4
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
	  ::Lib.gtk_widget_show self
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
	  ::Lib::CALLBACKS << _v2
	  _v3 = GirFFI::ArgHelper.object_to_inptr data
	  _v4 = GirFFI::ArgHelper.mapped_callback_args destroy_data
	  ::Lib::CALLBACKS << _v4
	  _v5 = ::Lib.g_signal_connect_data _v1, detailed_signal, _v2, _v3, _v4, connect_flags
	  return _v5
	end"

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Everything::TestObj#new_from_file" do
      go = get_method_introspection_data 'Everything', 'TestObj', 'new_from_file'
      fbuilder = GirFFI::FunctionDefinitionBuilder.new go, Lib
      code = fbuilder.generate

      expected =
	"def new_from_file x
	  _v3 = FFI::MemoryPointer.new(:pointer).write_pointer nil
	  _v1 = ::Lib.test_obj_new_from_file x, _v3
	  GirFFI::ArgHelper.check_error(_v3)
	  _v2 = ::Everything::TestObj._real_new(_v1)
	  GirFFI::ArgHelper.sink_if_floating(_v2)
	  return _v2
	end"

      assert_equal cws(expected), cws(code)
    end
  end
end
