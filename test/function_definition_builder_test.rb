require File.expand_path('test_helper.rb', File.dirname(__FILE__))

class FunctionDefinitionBuilderTest < Test::Unit::TestCase
  context "The Builder::Function class" do
    should "build correct definition of Gtk.init" do
      go = get_function_introspection_data 'Gtk', 'init'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected = "
	def init argv
	  argc = argv.length
	  _v1 = GirFFI::ArgHelper.int_to_inoutptr argc
	  _v3 = GirFFI::ArgHelper.utf8_array_to_inoutptr argv
	  ::Lib.gtk_init _v1, _v3
	  _v2 = GirFFI::ArgHelper.outptr_to_int _v1
	  GirFFI::ArgHelper.cleanup_ptr _v1
	  _v4 = GirFFI::ArgHelper.outptr_to_utf8_array _v3, _v2
	  GirFFI::ArgHelper.cleanup_ptr_array_ptr _v3, _v2
	  return _v4
	end
      "

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Gtk::Widget.show" do
      go = get_method_introspection_data 'Gtk', 'Widget', 'show'
      fbuilder = GirFFI::Builder::Function.new go, Lib
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
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected =
	"def signal_connect_data instance, detailed_signal, c_handler, data, destroy_data, connect_flags
	  _v1 = GirFFI::ArgHelper.object_to_inptr instance
	  _v2 = GirFFI::ArgHelper.utf8_to_inptr detailed_signal
	  _v3 = GirFFI::ArgHelper.wrap_in_callback_args_mapper \"GObject\", \"Callback\", c_handler
	  ::Lib::CALLBACKS << _v3
	  _v4 = GirFFI::ArgHelper.object_to_inptr data
	  _v5 = GirFFI::ArgHelper.wrap_in_callback_args_mapper \"GObject\", \"ClosureNotify\", destroy_data
	  ::Lib::CALLBACKS << _v5
	  _v6 = connect_flags
	  _v7 = ::Lib.g_signal_connect_data _v1, _v2, _v3, _v4, _v5, _v6
	  return _v7
	end"

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Everything::TestObj#new_from_file" do
      go = get_method_introspection_data 'Everything', 'TestObj', 'new_from_file'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected =
	"def new_from_file x
	  _v1 = GirFFI::ArgHelper.utf8_to_inptr x
	  _v4 = FFI::MemoryPointer.new(:pointer).write_pointer nil
	  _v2 = ::Lib.test_obj_new_from_file _v1, _v4
	  GirFFI::ArgHelper.check_error(_v4)
	  _v3 = ::Everything::TestObj.constructor_wrap(_v2)
	  return _v3
	end"

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Everything:test_array_int_null_in" do
      go = get_function_introspection_data 'Everything', 'test_array_int_null_in'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected =
	"def test_array_int_null_in arr
	  _v1 = GirFFI::ArgHelper.int_array_to_inptr arr
	  len = arr.nil? ? 0 : arr.length
	  _v2 = len
	  ::Lib.test_array_int_null_in _v1, _v2
	  GirFFI::ArgHelper.cleanup_ptr _v1
	end"

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Everything:test_array_int_null_out" do
      go = get_function_introspection_data 'Everything', 'test_array_int_null_out'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected =
	"def test_array_int_null_out
	  _v1 = GirFFI::ArgHelper.pointer_outptr
	  _v3 = GirFFI::ArgHelper.int_outptr
	  ::Lib.test_array_int_null_out _v1, _v3
	  _v4 = GirFFI::ArgHelper.outptr_to_int _v3
	  GirFFI::ArgHelper.cleanup_ptr _v3
	  _v2 = GirFFI::ArgHelper.outptr_to_int_array _v1, _v4
	  GirFFI::ArgHelper.cleanup_ptr_ptr _v1
	  return _v2
	end"

      assert_equal cws(expected), cws(code)
    end

    should "build correct definition of Everything:test_utf8_nonconst_in" do
      go = get_function_introspection_data 'Everything', 'test_utf8_nonconst_in'
      fbuilder = GirFFI::Builder::Function.new go, Lib
      code = fbuilder.generate

      expected =
	"def test_utf8_nonconst_in in_
	  _v1 = GirFFI::ArgHelper.utf8_to_inptr in_
	  ::Lib.test_utf8_nonconst_in _v1
	end"

      assert_equal cws(expected), cws(code)
    end
  end
end
