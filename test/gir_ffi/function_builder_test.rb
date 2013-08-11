require 'gir_ffi_test_helper'

describe GirFFI::FunctionBuilder do
  it "builds a correct definition of Regress:test_array_fixed_out_objects" do
    go = get_introspection_data 'Regress', 'test_array_fixed_out_objects'
    skip unless go
    fbuilder = GirFFI::FunctionBuilder.new go
    code = fbuilder.generate

    expected = <<-CODE
      def self.test_array_fixed_out_objects 
        _v1 = GirFFI::InOutPointer.for :c
        Regress::Lib.regress_test_array_fixed_out_objects _v1
        _v2 = GLib::SizedArray.wrap([:pointer, Regress::TestObj], 2, _v1.to_value)
        return _v2
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds a correct definition for functions having a linked length argument" do
    go = get_introspection_data 'Regress', 'test_array_gint16_in'
    fbuilder = GirFFI::FunctionBuilder.new go
    code = fbuilder.generate

    expected = <<-CODE
      def self.test_array_gint16_in ints
        n_ints = ints.nil? ? 0 : ints.length
        _v1 = n_ints
        _v2 = GLib::SizedArray.from(:gint16, -1, ints)
        _v3 = Regress::Lib.regress_test_array_gint16_in _v1, _v2
        return _v3
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds a correct definition for functions with callbacks" do
    go = get_introspection_data 'Regress', 'test_callback_destroy_notify'
    fbuilder = GirFFI::FunctionBuilder.new go
    code = fbuilder.generate

    expected = <<-CODE
      def self.test_callback_destroy_notify callback, user_data, notify
        _v1 = GirFFI::Callback.from(\"Regress\", \"TestCallbackUserData\", callback)
        _v2 = GirFFI::InPointer.from(:void, user_data)
        _v3 = GirFFI::Callback.from(\"GLib\", \"DestroyNotify\", notify)
        _v4 = Regress::Lib.regress_test_callback_destroy_notify _v1, _v2, _v3
        return _v4
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds correct definition for constructors" do
    go = get_method_introspection_data 'Regress', 'TestObj', 'new_from_file'
    fbuilder = GirFFI::FunctionBuilder.new go
    code = fbuilder.generate

    expected = <<-CODE
      def self.new_from_file x
        _v1 = GirFFI::InPointer.from(:utf8, x)
        _v2 = FFI::MemoryPointer.new(:pointer).write_pointer nil
        _v3 = Regress::Lib.regress_test_obj_new_from_file _v1, _v2
        GirFFI::ArgHelper.check_error(_v2)
        _v4 = self.constructor_wrap(_v3)
        return _v4
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "creates a call to GObject::Value#from for functions that take a GValue" do
    go = get_introspection_data 'GIMarshallingTests', 'gvalue_in'
    fbuilder = GirFFI::FunctionBuilder.new go
    code = fbuilder.generate

    expected = <<-CODE
      def self.gvalue_in value
        _v1 = ::GObject::Value.from(value)
        GIMarshallingTests::Lib.gi_marshalling_tests_gvalue_in _v1
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds correct definition for functions with a nullable input array" do
    go = get_introspection_data 'Regress', 'test_array_int_null_in'
    fbuilder = GirFFI::FunctionBuilder.new go
    code = fbuilder.generate

    expected = <<-CODE
      def self.test_array_int_null_in arr
        _v1 = GLib::SizedArray.from(:gint32, -1, arr)
        len = arr.nil? ? 0 : arr.length
        _v2 = len
        Regress::Lib.regress_test_array_int_null_in _v1, _v2
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds correct definition for functions with a nullable output array" do
    go = get_introspection_data 'Regress', 'test_array_int_null_out'
    fbuilder = GirFFI::FunctionBuilder.new go
    code = fbuilder.generate

    expected = <<-CODE
      def self.test_array_int_null_out 
        _v1 = GirFFI::InOutPointer.for :c
        _v2 = GirFFI::InOutPointer.for :gint32
        Regress::Lib.regress_test_array_int_null_out _v1, _v2
        _v3 = _v2.to_value
        _v4 = GLib::SizedArray.wrap(:gint32, _v3, _v1.to_value)
        return _v4
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds the correct definition for a method with an inout array with size argument" do
    go = get_method_introspection_data 'GIMarshallingTests', 'Object', 'method_array_inout'
    fbuilder = GirFFI::FunctionBuilder.new go
    code = fbuilder.generate

    expected = <<-CODE
      def method_array_inout ints
        _v1 = GirFFI::InOutPointer.from :c, GLib::SizedArray.from(:gint32, -1, ints)
        length = ints.nil? ? 0 : ints.length
        _v2 = GirFFI::InOutPointer.from :gint32, length
        GIMarshallingTests::Lib.gi_marshalling_tests_object_method_array_inout self, _v1, _v2
        _v3 = _v2.to_value
        _v4 = GLib::SizedArray.wrap(:gint32, _v3, _v1.to_value)
        return _v4
      end
    CODE

    assert_equal expected.reset_indentation, code
  end

  it "builds a correct definition for a simple method" do
    go = get_method_introspection_data 'Regress', 'TestObj', 'instance_method'
    fbuilder = GirFFI::FunctionBuilder.new go
    code = fbuilder.generate

    expected = <<-CODE
      def instance_method 
        _v1 = Regress::Lib.regress_test_obj_instance_method self
        return _v1
      end
    CODE

    assert_equal expected.reset_indentation, code
  end
end
