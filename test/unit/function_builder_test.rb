require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Function do
  describe "#pretty_print" do
    it "delegates to #generate" do
      builder = GirFFI::Builder::Function.new(:info, :libmodule)

      mock(builder).generate { 'result_from_generate' }

      assert_equal "result_from_generate", builder.pretty_print
    end
  end

  it "builds a correct definition of Regress:test_array_fixed_out_objects" do
    go = get_introspection_data 'Regress', 'test_array_fixed_out_objects'
    fbuilder = GirFFI::Builder::Function.new go, Lib
    code = fbuilder.generate

    expected = <<-CODE
      def test_array_fixed_out_objects 
        _v1 = GirFFI::InOutPointer.for_array [:pointer, ::Regress::TestObj]
        ::Lib.regress_test_array_fixed_out_objects _v1
        _v2 = _v1.to_sized_array_value 2
        return _v2
      end
      CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds a correct definition for methods having a linked length argument" do
    go = get_introspection_data 'Regress', 'test_array_gint16_in'
    fbuilder = GirFFI::Builder::Function.new go, Lib
    code = fbuilder.generate

    expected = <<-CODE
      def test_array_gint16_in ints
        n_ints = ints.nil? ? 0 : ints.length
        _v1 = n_ints
        _v2 = GirFFI::InPointer.from_array :gint16, ints
        _v3 = ::Lib.regress_test_array_gint16_in _v1, _v2
        return _v3
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds a correct definition for methods with callbacks" do
    go = get_introspection_data 'Regress', 'test_callback_destroy_notify'
    fbuilder = GirFFI::Builder::Function.new go, Lib
    code = fbuilder.generate

    expected = <<-CODE
      def test_callback_destroy_notify callback, user_data, notify
        _v1 = GirFFI::CallbackHelper.wrap_in_callback_args_mapper \"Regress\", \"TestCallbackUserData\", callback
        ::Lib::CALLBACKS << _v1
        _v2 = GirFFI::ArgHelper.object_to_inptr user_data
        _v3 = GirFFI::CallbackHelper.wrap_in_callback_args_mapper \"GLib\", \"DestroyNotify\", notify
        ::Lib::CALLBACKS << _v3
        _v4 = ::Lib.regress_test_callback_destroy_notify _v1, _v2, _v3
        return _v4
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds correct definition for constructors" do
    go = get_method_introspection_data 'Regress', 'TestObj', 'new_from_file'
    fbuilder = GirFFI::Builder::Function.new go, Lib
    code = fbuilder.generate

    expected = <<-CODE
      def new_from_file x
        _v1 = GirFFI::InPointer.from :utf8, x
        _v2 = FFI::MemoryPointer.new(:pointer).write_pointer nil
        _v3 = ::Lib.regress_test_obj_new_from_file _v1, _v2
        GirFFI::ArgHelper.check_error(_v2)
        _v4 = self.constructor_wrap(_v3)
        return _v4
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds correct definition for methods with a nullable input array" do
    go = get_introspection_data 'Regress', 'test_array_int_null_in'
    fbuilder = GirFFI::Builder::Function.new go, Lib
    code = fbuilder.generate

    expected = <<-CODE
      def test_array_int_null_in arr
        _v1 = GirFFI::InPointer.from_array :gint32, arr
        len = arr.nil? ? 0 : arr.length
        _v2 = len
        ::Lib.regress_test_array_int_null_in _v1, _v2
        
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds correct definition for methods with a nullable output array" do
    go = get_introspection_data 'Regress', 'test_array_int_null_out'
    fbuilder = GirFFI::Builder::Function.new go, Lib
    code = fbuilder.generate

    expected = <<-CODE
      def test_array_int_null_out 
        _v1 = GirFFI::InOutPointer.for_array :gint32
        _v2 = GirFFI::InOutPointer.for :gint32
        ::Lib.regress_test_array_int_null_out _v1, _v2
        _v3 = _v2.to_value
        _v4 = _v1.to_sized_array_value _v3
        return _v4
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds the correct definition for a method with an inout array with size argument" do
    go = get_method_introspection_data 'GIMarshallingTests', 'Object', 'method_array_inout'
    fbuilder = GirFFI::Builder::Function.new go, Lib
    code = fbuilder.generate

    expected = <<-CODE
      def method_array_inout ints
        _v1 = GirFFI::InOutPointer.from_array :gint32, ints
        length = ints.length
        _v2 = GirFFI::InOutPointer.from :gint32, length
        ::Lib.gi_marshalling_tests_object_method_array_inout self, _v1, _v2
        _v3 = _v2.to_value
        _v4 = _v1.to_sized_array_value _v3
        return _v4
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds a correct definition for a simple method" do
    go = get_method_introspection_data 'Gtk', 'Widget', 'show'
    fbuilder = GirFFI::Builder::Function.new go, Lib
    code = fbuilder.generate

    expected = <<-CODE
      def show 
        ::Lib.gtk_widget_show self
        
      end
    CODE

    assert_equal expected.reset_indentation, code
  end
end
