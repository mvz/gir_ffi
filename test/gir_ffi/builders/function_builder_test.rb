require 'gir_ffi_test_helper'

describe GirFFI::Builders::FunctionBuilder do
  describe '#method_definition' do
    let(:builder) { GirFFI::Builders::FunctionBuilder.new function_info }
    let(:code) { builder.method_definition }

    describe 'for Regress:test_array_fixed_out_objects' do
      let(:function_info) { get_introspection_data 'Regress', 'test_array_fixed_out_objects' }
      it 'builds a correct definition' do
        skip unless function_info
        code.must_equal <<-CODE.reset_indentation
          def self.test_array_fixed_out_objects
            _v1 = GirFFI::InOutPointer.for [:pointer, :c]
            Regress::Lib.regress_test_array_fixed_out_objects _v1
            _v2 = GirFFI::SizedArray.wrap([:pointer, Regress::TestObj], 2, _v1.to_value)
            return _v2
          end
        CODE
      end
    end

    describe 'for functions having a linked length argument' do
      let(:function_info) { get_introspection_data 'Regress', 'test_array_gint16_in' }
      it 'builds a correct definition' do
        code.must_equal <<-CODE.reset_indentation
          def self.test_array_gint16_in(ints)
            n_ints = ints.nil? ? 0 : ints.length
            _v1 = n_ints
            _v2 = GirFFI::SizedArray.from(:gint16, -1, ints)
            _v3 = Regress::Lib.regress_test_array_gint16_in _v1, _v2
            return _v3
          end
        CODE
      end
    end

    describe 'for functions with callbacks' do
      let(:function_info) { get_introspection_data 'Regress', 'test_callback_destroy_notify' }
      it 'builds a correct definition' do
        code.must_equal <<-CODE.reset_indentation
          def self.test_callback_destroy_notify(callback, user_data, notify)
            _v1 = Regress::TestCallbackUserData.from(callback)
            _v2 = GirFFI::InPointer.from_closure_data(user_data)
            _v3 = GLib::DestroyNotify.from(notify)
            _v4 = Regress::Lib.regress_test_callback_destroy_notify _v1, _v2, _v3
            return _v4
          end
        CODE
      end
    end

    describe 'for functions that take a GValue' do
      let(:function_info) { get_introspection_data 'GIMarshallingTests', 'gvalue_in' }
      it 'creates a call to GObject::Value#from' do
        code.must_equal <<-CODE.reset_indentation
          def self.gvalue_in(value)
            _v1 = GObject::Value.from(value)
            GIMarshallingTests::Lib.gi_marshalling_tests_gvalue_in _v1
          end
        CODE
      end
    end

    describe 'for functions that have a GValue out argument' do
      let(:function_info) { get_introspection_data 'GIMarshallingTests', 'gvalue_out' }
      it 'creates a call to #get_value' do
        code.must_equal <<-CODE.reset_indentation
          def self.gvalue_out
            _v1 = GirFFI::InOutPointer.for [:pointer, GObject::Value]
            GIMarshallingTests::Lib.gi_marshalling_tests_gvalue_out _v1
            _v2 = GObject::Value.wrap(_v1.to_value).get_value
            return _v2
          end
        CODE
      end
    end

    describe 'for functions with a nullable input array' do
      let(:function_info) { get_introspection_data 'Regress', 'test_array_int_null_in' }
      it 'builds correct definition' do
        code.must_equal <<-CODE.reset_indentation
          def self.test_array_int_null_in(arr)
            len = arr.nil? ? 0 : arr.length
            _v1 = len
            _v2 = GirFFI::SizedArray.from(:gint32, -1, arr)
            Regress::Lib.regress_test_array_int_null_in _v2, _v1
          end
        CODE
      end
    end

    describe 'for functions with a nullable output array' do
      let(:function_info) { get_introspection_data 'Regress', 'test_array_int_null_out' }
      it 'builds correct definition' do
        code.must_equal <<-CODE.reset_indentation
          def self.test_array_int_null_out
            _v1 = GirFFI::InOutPointer.for :gint32
            _v2 = GirFFI::InOutPointer.for [:pointer, :c]
            Regress::Lib.regress_test_array_int_null_out _v2, _v1
            _v3 = _v1.to_value
            _v4 = GirFFI::SizedArray.wrap(:gint32, _v3, _v2.to_value)
            return _v4
          end
        CODE
      end
    end

    describe 'for a method with an inout array with size argument' do
      let(:function_info) { get_method_introspection_data 'GIMarshallingTests', 'Object', 'method_array_inout' }
      it 'builds the correct definition' do
        code.must_equal <<-CODE.reset_indentation
          def method_array_inout(ints)
            length = ints.nil? ? 0 : ints.length
            _v1 = GirFFI::InOutPointer.for :gint32
            _v1.set_value length
            _v2 = GirFFI::InOutPointer.for [:pointer, :c]
            _v2.set_value GirFFI::SizedArray.from(:gint32, -1, ints)
            GIMarshallingTests::Lib.gi_marshalling_tests_object_method_array_inout self, _v2, _v1
            _v3 = _v1.to_value
            _v4 = GirFFI::SizedArray.wrap(:gint32, _v3, _v2.to_value)
            return _v4
          end
        CODE
      end
    end

    describe 'for a simple method' do
      let(:function_info) { get_method_introspection_data 'Regress', 'TestObj', 'instance_method' }

      it 'builds a correct definition' do
        code.must_equal <<-CODE.reset_indentation
          def instance_method
            _v1 = Regress::Lib.regress_test_obj_instance_method self
            return _v1
          end
        CODE
      end
    end

    describe 'for GLib::Variant.get_strv' do
      let(:function_info) { get_method_introspection_data 'GLib', 'Variant', 'get_strv' }
      it 'builds a correct definition' do
        size_type = ":guint#{FFI.type_size(:size_t) * 8}"
        code.must_equal <<-CODE.reset_indentation
          def get_strv
            _v1 = GirFFI::InOutPointer.for #{size_type}
            _v2 = GLib::Lib.g_variant_get_strv self, _v1
            _v3 = GLib::Strv.wrap(_v2)
            return _v3
          end
        CODE
      end
    end

    describe 'for Regress.has_parameter_named_attrs' do
      let(:function_info) { get_introspection_data 'Regress', 'has_parameter_named_attrs' }

      it 'builds a correct definition' do
        skip unless function_info
        code.must_equal <<-CODE.reset_indentation
          def self.has_parameter_named_attrs(foo, attributes)
            _v1 = foo
            GirFFI::ArgHelper.check_fixed_array_size 32, attributes, \"attributes\"
            _v2 = GirFFI::SizedArray.from([:pointer, :guint32], 32, attributes)
            Regress::Lib.regress_has_parameter_named_attrs _v1, _v2
          end
        CODE
      end
    end

    describe 'for GIMarshallingTests::Object#method_int8_arg_and_out_callee' do
      let(:function_info) do
        get_method_introspection_data('GIMarshallingTests', 'Object',
                                      'method_int8_arg_and_out_callee')
      end

      it 'builds a correct definition' do
        skip unless function_info
        code.must_equal <<-CODE.reset_indentation
          def method_int8_arg_and_out_callee(arg)
            _v1 = arg
            _v2 = GirFFI::InOutPointer.for [:pointer, :gint8]
            GIMarshallingTests::Lib.gi_marshalling_tests_object_method_int8_arg_and_out_callee self, _v1, _v2
            _v3 = GirFFI::InOutPointer.new(:gint8, _v2.to_value).to_value
            return _v3
          end
        CODE
      end
    end

    describe 'for GIMarshallingTests::Object.full_inout' do
      let(:function_info) do
        get_method_introspection_data('GIMarshallingTests', 'Object',
                                      'full_inout')
      end

      it 'builds a correct definition' do
        code.must_equal <<-CODE.reset_indentation
          def self.full_inout(object)
            _v1 = GirFFI::InOutPointer.for [:pointer, GIMarshallingTests::Object]
            _v1.set_value GIMarshallingTests::Object.from(object.ref)
            GIMarshallingTests::Lib.gi_marshalling_tests_object_full_inout _v1
            _v2 = GIMarshallingTests::Object.wrap(_v1.to_value)
            return _v2
          end
        CODE
      end
    end

    describe 'for Regress::TestObj#instance_method_full' do
      let(:function_info) do
        get_method_introspection_data('Regress', 'TestObj',
                                      'instance_method_full')
      end

      it 'builds a correct definition including self.ref' do
        skip unless function_info
        code.must_equal <<-CODE.reset_indentation
          def instance_method_full
            Regress::Lib.regress_test_obj_instance_method_full self.ref
          end
        CODE
      end
    end
  end
end
