# coding: utf-8
require 'gir_ffi_test_helper'

require 'gir_ffi'

GirFFI.setup :GIMarshallingTests

# Tests generated methods and functions in the GIMarshallingTests namespace.
describe GIMarshallingTests do
  let(:derived_klass) do
    Object.const_set("DerivedClass#{Sequence.next}",
                     Class.new(GIMarshallingTests::Object))
  end

  def make_derived_instance
    GirFFI.define_type derived_klass do |info|
      yield info if block_given?
    end
    derived_klass.new
  end

  describe 'GIMarshallingTests::BoxedStruct' do
    let(:instance) { GIMarshallingTests::BoxedStruct.new }

    it 'has a writable field long_' do
      instance.long_ = 42
      assert_equal 42, instance.long_
      instance.long_ = 43
      assert_equal 43, instance.long_
    end

    it 'has a writable field string_' do
      skip unless get_field_introspection_data('GIMarshallingTests', 'BoxedStruct', 'string_')
      instance.string_ = 'foobar'
      instance.string_.must_equal 'foobar'
    end

    it 'has a writable field g_strv' do
      instance.g_strv.must_be :==, []
      instance.g_strv = %w(foo bar)
      instance.g_strv.must_be :==, %w(foo bar)
    end

    it 'creates an instance using #new' do
      bx = GIMarshallingTests::BoxedStruct.new
      assert_instance_of GIMarshallingTests::BoxedStruct, bx
    end

    it 'has a working method #inv' do
      instance.long_ = 42
      instance.inv
      pass
    end

    it 'has a working function #inout' do
      bx = GIMarshallingTests::BoxedStruct.new
      bx.long_ = 42

      res = GIMarshallingTests::BoxedStruct.inout bx

      # TODO: Deal with the fact that bx is now invalid (at least with
      # gobject-introspection 1.40).

      assert_equal 0, res.long_
    end

    it 'has a working function #out' do
      res = GIMarshallingTests::BoxedStruct.out
      assert_equal 42, res.long_
    end

    it 'has a working function #returnv' do
      res = GIMarshallingTests::BoxedStruct.returnv
      assert_equal 42, res.long_
      res.g_strv.must_be :==, %w(0 1 2)
    end
  end

  it 'has the constant CONSTANT_GERROR_CODE' do
    assert_equal 5, GIMarshallingTests::CONSTANT_GERROR_CODE
  end

  it 'has the constant CONSTANT_GERROR_DEBUG_MESSAGE' do
    GIMarshallingTests::CONSTANT_GERROR_DEBUG_MESSAGE.must_equal(
      'we got an error, life is shit')
  end

  it 'has the constant CONSTANT_GERROR_DOMAIN' do
    assert_equal 'gi-marshalling-tests-gerror-domain',
                 GIMarshallingTests::CONSTANT_GERROR_DOMAIN
  end

  it 'has the constant CONSTANT_GERROR_MESSAGE' do
    assert_equal 'gi-marshalling-tests-gerror-message',
                 GIMarshallingTests::CONSTANT_GERROR_MESSAGE
  end

  it 'has the constant CONSTANT_NUMBER' do
    assert_equal 42, GIMarshallingTests::CONSTANT_NUMBER
  end

  it 'has the constant CONSTANT_UTF8' do
    assert_equal 'const ♥ utf8', GIMarshallingTests::CONSTANT_UTF8
  end

  describe 'GIMarshallingTests::Enum' do
    it 'has the member :value1' do
      assert_equal 0, GIMarshallingTests::Enum[:value1]
    end

    it 'has the member :value2' do
      assert_equal 1, GIMarshallingTests::Enum[:value2]
    end

    it 'has the member :value3' do
      assert_equal 42, GIMarshallingTests::Enum[:value3]
    end
  end

  describe 'GIMarshallingTests::Flags' do
    it 'has the member :value1' do
      assert_equal 1, GIMarshallingTests::Flags[:value1]
    end

    it 'has the member :value2' do
      assert_equal 2, GIMarshallingTests::Flags[:value2]
    end

    it 'has the member :value3' do
      assert_equal 4, GIMarshallingTests::Flags[:value3]
    end

    it 'has the member :mask' do
      assert_equal 3, GIMarshallingTests::Flags[:mask]
    end

    it 'has the member :mask2' do
      assert_equal 3, GIMarshallingTests::Flags[:mask2]
    end

    it 'has a working function #in' do
      GIMarshallingTests::Flags.in :value2
    end

    it 'has a working function #in_zero' do
      GIMarshallingTests::Flags.in_zero 0
    end

    it 'has a working function #inout' do
      result = GIMarshallingTests::Flags.inout :value2
      result.must_equal :value1
    end

    it 'has a working function #out' do
      result = GIMarshallingTests::Flags.out
      result.must_equal :value2
    end

    it 'has a working function #returnv' do
      result = GIMarshallingTests::Flags.returnv
      result.must_equal :value2
    end
  end

  describe 'GIMarshallingTests::GEnum' do
    it 'has the member :value1' do
      assert_equal 0, GIMarshallingTests::GEnum[:value1]
    end

    it 'has the member :value2' do
      assert_equal 1, GIMarshallingTests::GEnum[:value2]
    end

    it 'has the member :value3' do
      assert_equal 42, GIMarshallingTests::GEnum[:value3]
    end

    it 'has a working function #in' do
      GIMarshallingTests::GEnum.in :value3
    end

    it 'has a working function #inout' do
      result = GIMarshallingTests::GEnum.inout :value3
      result.must_equal :value1
    end

    it 'has a working function #out' do
      result = GIMarshallingTests::GEnum.out
      result.must_equal :value3
    end

    it 'has a working function #returnv' do
      result = GIMarshallingTests::GEnum.returnv
      result.must_equal :value3
    end
  end

  describe 'GIMarshallingTests::Interface' do
    it 'has a working method #test_int8_in' do
      derived_klass.class_eval { include GIMarshallingTests::Interface }
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :test_int8_in, proc { |obj, in_| obj.int = in_ }
      end
      derived_instance.test_int8_in 8
      derived_instance.int.must_equal 8
    end
  end

  describe 'GIMarshallingTests::Interface2' do
    it 'must be tested for clashes with Interface' do
      skip 'Needs more work to determine desired behavior'
    end
  end

  describe 'GIMarshallingTests::Interface3' do
    it 'has a working method #test_variant_array_in' do
      skip unless get_introspection_data 'GIMarshallingTests', 'Interface3'
      derived_klass.class_eval { include GIMarshallingTests::Interface3 }
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :test_variant_array_in, proc {|obj, in_|
          obj.int = in_.to_a.first.get_byte
        }
      end
      derived_instance.test_variant_array_in [GLib::Variant.new_byte(42)]
      derived_instance.int.must_equal 42
    end
  end

  describe 'GIMarshallingTests::InterfaceImpl' do
    before do
      skip unless get_introspection_data 'GIMarshallingTests', 'InterfaceImpl'
    end

    it 'has a working method #get_as_interface' do
      obj = GIMarshallingTests::InterfaceImpl.new []
      result = obj.get_as_interface
      result.must_be_kind_of GIMarshallingTests::Interface
    end
  end

  describe 'GIMarshallingTests::NestedStruct' do
    let(:instance) { GIMarshallingTests::NestedStruct.new }
    it 'has a writable field simple_struct' do
      assert_instance_of GIMarshallingTests::SimpleStruct,
                         instance.simple_struct
      new_struct = GIMarshallingTests::SimpleStruct.new
      new_struct.int8 = 42
      instance.simple_struct = new_struct
      instance.simple_struct.int8.must_equal 42
    end
  end

  describe 'GIMarshallingTests::NoTypeFlags' do
    it 'has the member :value1' do
      assert_equal 1, GIMarshallingTests::NoTypeFlags[:value1]
    end
    it 'has the member :value2' do
      assert_equal 2, GIMarshallingTests::NoTypeFlags[:value2]
    end
    it 'has the member :value3' do
      assert_equal 4, GIMarshallingTests::NoTypeFlags[:value3]
    end
    it 'has the member :mask' do
      assert_equal 3, GIMarshallingTests::NoTypeFlags[:mask]
    end
    it 'has the member :mask2' do
      assert_equal 3, GIMarshallingTests::NoTypeFlags[:mask2]
    end
  end

  describe 'GIMarshallingTests::NotSimpleStruct' do
    let(:instance) { GIMarshallingTests::NotSimpleStruct.new }

    it 'has a writable field pointer' do
      instance.pointer.must_be_nil
      nested = GIMarshallingTests::NestedStruct.new
      instance.pointer = nested
      instance.pointer.must_equal nested
    end
  end

  it 'has the constant OVERRIDES_CONSTANT' do
    assert_equal 42, GIMarshallingTests::OVERRIDES_CONSTANT
  end

  describe 'GIMarshallingTests::Object' do
    it 'creates an instance using #new' do
      ob = GIMarshallingTests::Object.new 42
      assert_instance_of GIMarshallingTests::Object, ob
      assert_equal 42, ob.int
    end

    it 'fails to create an instance using #new_fail' do
      skip unless get_method_introspection_data('GIMarshallingTests', 'Object', 'new_fail')
      proc { GIMarshallingTests::Object.new_fail 42 }.must_raise GirFFI::GLibError
    end

    it 'has a working function #full_inout' do
      ob = GIMarshallingTests::Object.new 42
      ref_count(ob).must_equal 1

      res = GIMarshallingTests::Object.full_inout ob

      ref_count(ob).must_be :>, 0
      ref_count(res).must_equal 1

      res.must_be_instance_of GIMarshallingTests::Object
      res.int.must_equal 0
    end

    it 'has a working function #full_out' do
      res = GIMarshallingTests::Object.full_out
      assert_instance_of GIMarshallingTests::Object, res
    end

    it 'has a working function #full_return' do
      res = GIMarshallingTests::Object.full_return
      assert_instance_of GIMarshallingTests::Object, res
    end

    it 'has a working function #inout_same' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working function #none_inout' do
      ob = GIMarshallingTests::Object.new 42
      res = GIMarshallingTests::Object.none_inout ob
      assert_instance_of GIMarshallingTests::Object, res
      ob.wont_equal res
    end

    it 'has a working function #none_out' do
      res = GIMarshallingTests::Object.none_out
      assert_instance_of GIMarshallingTests::Object, res
    end

    it 'has a working function #none_return' do
      res = GIMarshallingTests::Object.none_return
      assert_instance_of GIMarshallingTests::Object, res
    end

    it 'has a working function #static_method' do
      GIMarshallingTests::Object.static_method
      pass
    end

    let(:instance) { GIMarshallingTests::Object.new 42 }

    it 'has a working method #call_vfunc_with_callback' do
      skip unless get_method_introspection_data('GIMarshallingTests', 'Object',
                                                'call_vfunc_with_callback')
      cb = nil
      user_data = nil
      result = nil

      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_with_callback, proc { |_obj, callback, callback_data|
          cb = callback
          user_data = callback_data.address
          result = callback.call(42, callback_data)
        }
      end
      derived_instance.call_vfunc_with_callback

      user_data.must_equal 0xdeadbeef
      # TODO: Change implementation of CallbackBase so that this becomes an
      # instance of GIMarshallingTests::CallbackIntInt
      cb.must_be_instance_of FFI::Function
      result.must_equal 42
    end

    it 'has a working method #full_in' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working method #get_ref_info_for_vfunc_in_object_transfer_full' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'vfunc_in_object_transfer_full')
      obj = nil
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_in_object_transfer_full, proc {|_this, object|
          obj = object
        }
      end
      result = derived_instance.
        get_ref_info_for_vfunc_in_object_transfer_full GIMarshallingTests::Object.gtype
      result.must_equal [1, false]
      obj.must_be_instance_of GIMarshallingTests::Object
    end

    it 'has a working method #get_ref_info_for_vfunc_in_object_transfer_none' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'vfunc_in_object_transfer_none')
      obj = nil
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_in_object_transfer_none, proc {|_this, object|
          obj = object
        }
      end
      result = derived_instance.
        get_ref_info_for_vfunc_in_object_transfer_none GIMarshallingTests::Object.gtype
      ref_count(obj).must_be :>, 0
      result.must_equal [2, false]
      obj.must_be_instance_of GIMarshallingTests::Object
    end

    it 'has a working method #get_ref_info_for_vfunc_out_object_transfer_full' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'vfunc_out_object_transfer_full')
      obj = nil
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_out_object_transfer_full, proc {|_obj|
          obj = GIMarshallingTests::Object.new(42)
        }
      end
      result = derived_instance.get_ref_info_for_vfunc_out_object_transfer_full
      ref_count(obj).must_be :>, 0
      # TODO: Check desired result
      result.must_equal [2, false]
    end

    it 'has a working method #get_ref_info_for_vfunc_out_object_transfer_none' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'vfunc_out_object_transfer_none')
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_out_object_transfer_none, proc {|_obj|
          GIMarshallingTests::Object.new 42
        }
      end
      result = derived_instance.get_ref_info_for_vfunc_out_object_transfer_none
      result.must_equal [1, false]
    end

    it 'has a working method #get_ref_info_for_vfunc_return_object_transfer_full' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'vfunc_return_object_transfer_full')
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_return_object_transfer_full, proc {|_obj|
          GIMarshallingTests::Object.new 42
        }
      end
      result = derived_instance.get_ref_info_for_vfunc_return_object_transfer_full
      result.must_equal [2, false]
    end

    it 'has a working method #get_ref_info_for_vfunc_return_object_transfer_none' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'vfunc_return_object_transfer_none')
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_return_object_transfer_none, proc {|_obj|
          GIMarshallingTests::Object.new 42
        }
      end
      result = derived_instance.get_ref_info_for_vfunc_return_object_transfer_none
      result.must_equal [1, false]
    end

    it 'has a working method #int8_in' do
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :method_int8_in, proc { |obj, in_| obj.int = in_ }
      end
      derived_instance.int8_in 23
      derived_instance.int.must_equal 23
    end

    # TODO: Check if this is fixed
    # See https://bugzilla.gnome.org/show_bug.cgi?id=727665
    it 'has a working method #int8_out' do
      skip 'Introspection data is not generated correctly'
    end

    it 'has a working method #method' do
      instance.method
      pass
    end

    it 'has a working method #method_array_in' do
      instance.method_array_in [-1, 0, 1, 2]
      pass
    end

    it 'has a working method #method_array_inout' do
      res = instance.method_array_inout [-1, 0, 1, 2]
      res.must_be :==, [-2, -1, 0, 1, 2]
    end

    it 'has a working method #method_array_out' do
      res = instance.method_array_out
      res.must_be :==, [-1, 0, 1, 2]
    end

    it 'has a working method #method_array_return' do
      res = instance.method_array_return
      res.must_be :==, [-1, 0, 1, 2]
    end

    it 'has a working method #method_int8_arg_and_out_callee' do
      skip unless get_method_introspection_data('GIMarshallingTests', 'Object',
                                                'method_int8_arg_and_out_callee')
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :method_int8_arg_and_out_callee, proc { |_obj, arg|
          2 * arg
        }
      end
      result = derived_instance.method_int8_arg_and_out_callee 32
      result.must_equal 64
    end

    it 'has a working method #method_int8_arg_and_out_caller' do
      skip unless get_method_introspection_data('GIMarshallingTests', 'Object',
                                                'method_int8_arg_and_out_caller')
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :method_int8_arg_and_out_caller, proc { |_obj, arg|
          2 * arg
        }
      end
      result = derived_instance.method_int8_arg_and_out_caller 32
      result.must_equal 64
    end

    it 'has a working method #method_int8_in' do
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :method_int8_in, proc { |obj, in_| obj.int = in_ }
      end
      derived_instance.method_int8_in 108
      derived_instance.int.must_equal 108
    end

    it 'has a working method #method_int8_out' do
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :method_int8_out, proc { |_obj| 42 }
      end
      derived_instance.method_int8_out.must_equal 42
    end

    it 'has a working method #method_str_arg_out_ret' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'method_str_arg_out_ret')
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :method_str_arg_out_ret, proc { |_obj, arg| [arg, 42] }
      end
      derived_instance.method_str_arg_out_ret('foo').must_equal ['foo', 42]
    end

    it 'has a working method #method_variant_array_in' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working method #method_with_default_implementation' do
      instance.method_with_default_implementation 104
      assert_equal 104, instance.int
    end

    it 'has a working method #none_in' do
      instance.none_in
      pass
    end

    it 'has a working method #overridden_method' do
      instance.set_property('int', 0)
      instance.overridden_method
      pass
    end

    it 'has a working method #vfunc_array_out_parameter' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'vfunc_array_out_parameter')
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_array_out_parameter, proc {|_obj|
          [1.1, 2.2, 3.3]
        }
      end
      result = derived_instance.vfunc_array_out_parameter
      arr = result.to_a
      arr.length.must_equal 3
      arr[0].must_be_close_to 1.1
      arr[1].must_be_close_to 2.2
      arr[2].must_be_close_to 3.3
    end

    it 'has a working method #vfunc_caller_allocated_out_parameter' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'vfunc_caller_allocated_out_parameter')
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_caller_allocated_out_parameter, proc {|_obj|
          'Hello!'
        }
      end
      result = derived_instance.vfunc_caller_allocated_out_parameter
      result.must_equal 'Hello!'
    end

    it 'has a working method #vfunc_meth_with_error' do
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_meth_with_err, proc {|_object, x|
          raise 'This is not the answer!' unless x == 42
          true
        }
      end
      result = derived_instance.vfunc_meth_with_error 42
      result.must_equal true

      err = proc { derived_instance.vfunc_meth_with_error(21) }.
        must_raise GirFFI::GLibError
      err.message.must_equal 'This is not the answer!'
      err.domain.must_equal 'gir_ffi'
      err.code.must_equal 0
    end

    it 'has a working method #vfunc_multiple_out_parameters' do
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation(
          :vfunc_multiple_out_parameters,
          proc { |*_args| [42.1, -142.3] })
      end
      result = derived_instance.vfunc_multiple_out_parameters
      result[0].must_be_close_to 42.1
      result[1].must_be_close_to(-142.3)
    end

    it 'has a working method #vfunc_one_out_parameter' do
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation(
          :vfunc_one_out_parameter,
          proc { |*_args| 23.4 })
      end
      derived_instance.vfunc_one_out_parameter.
        must_be_within_epsilon 23.4
    end

    it 'has a working method #vfunc_out_enum' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'vfunc_out_enum')
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_out_enum, proc { |_obj| :value2 }
      end
      derived_instance.vfunc_out_enum.must_equal :value2
    end

    it 'has a working method #vfunc_return_enum' do
      skip unless get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                               'vfunc_return_enum')
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_return_enum, proc { |_obj| :value2 }
      end
      derived_instance.vfunc_return_enum.must_equal :value2
    end

    it 'has a working method #vfunc_return_value_and_multiple_out_parameters' do
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation(
          :vfunc_return_value_and_multiple_out_parameters,
          proc { |*_args| [42, -142, 3] })
      end
      derived_instance.vfunc_return_value_and_multiple_out_parameters.
        must_equal [42, -142, 3]
    end

    it 'has a working method #vfunc_return_value_and_one_out_parameter' do
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation(
          :vfunc_return_value_and_one_out_parameter,
          proc { |*_args| [42, -142] })
      end
      derived_instance.vfunc_return_value_and_one_out_parameter.
        must_equal [42, -142]
    end

    it 'has a working method #vfunc_return_value_only' do
      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_return_value_only, proc { |_obj| 0x1234_5678 }
      end
      result = derived_instance.vfunc_return_value_only
      result.must_equal 0x1234_5678
    end

    it 'has a working method #vfunc_with_callback' do
      skip unless get_method_introspection_data('GIMarshallingTests', 'Object',
                                                'vfunc_with_callback')

      result = 1

      derived_instance = make_derived_instance do |info|
        info.install_vfunc_implementation :vfunc_with_callback, proc { |_obj, callback, callback_data|
          callback.call(42, callback_data)
        }
      end

      derived_instance.vfunc_with_callback proc { |val, user_data| result = val + user_data }, 23

      # The current implementation of the vfunc_with_callback method currently
      # doesn't actually call the virtual function vfunc_with_callback.
      result.must_equal 1
      result.wont_equal 42 + 23
    end

    describe "its 'int' property" do
      it 'can be retrieved with #get_property' do
        assert_equal 42, instance.get_property('int')
      end
      it 'can be retrieved with #int' do
        assert_equal 42, instance.int
      end
      it 'can be set with #set_property' do
        instance.set_property('int', 13)
        assert_equal 13, instance.get_property('int')
      end
      it 'can be set with #int=' do
        instance.int = 1
        assert_equal 1, instance.int
      end
    end
  end

  describe 'GIMarshallingTests::OverridesObject' do
    it 'creates an instance using #new' do
      ob = GIMarshallingTests::OverridesObject.new
      assert_instance_of GIMarshallingTests::OverridesObject, ob
    end

    it 'has a working function #returnv' do
      ob = GIMarshallingTests::OverridesObject.returnv
      assert_instance_of GIMarshallingTests::OverridesObject, ob
    end

    let(:instance) { GIMarshallingTests::OverridesObject.new }

    it 'has a working method #method' do
      result = instance.method
      result.must_equal 42
    end

    it 'does not have field accessor methods' do
      assert_raises(NoMethodError) { instance.parent_instance }
      assert_raises(NoMethodError) { instance.parent_instance = nil }
      assert_raises(NoMethodError) { instance.long_ }
      assert_raises(NoMethodError) { instance.long_ = 1 }
    end
  end

  describe 'GIMarshallingTests::OverridesStruct' do
    let(:instance) { GIMarshallingTests::OverridesStruct.new }

    it 'has a writable field long_' do
      instance.long_ = 43
      instance.long_.must_equal 43
    end

    it 'creates an instance using #new' do
      ob = GIMarshallingTests::OverridesStruct.new
      assert_instance_of GIMarshallingTests::OverridesStruct, ob
    end

    it 'has a working method #method' do
      instance.method.must_equal 42
    end

    it 'has a working function #returnv' do
      ob = GIMarshallingTests::OverridesStruct.returnv
      assert_instance_of GIMarshallingTests::OverridesStruct, ob
    end
  end

  describe 'GIMarshallingTests::PointerStruct' do
    it 'creates an instance using #new' do
      ps = GIMarshallingTests::PointerStruct.new
      assert_instance_of GIMarshallingTests::PointerStruct, ps
    end

    let(:instance) { GIMarshallingTests::PointerStruct.new }

    it 'has a writable field long_' do
      assert_equal 0, instance.long_
      instance.long_ = 1056
      assert_equal 1056, instance.long_
    end

    it 'has a working method #inv' do
      instance.long_ = 42
      instance.inv
      pass
    end

    it 'has a working function #returnv' do
      ob = GIMarshallingTests::PointerStruct.returnv
      assert_instance_of GIMarshallingTests::PointerStruct, ob
    end
  end

  describe 'GIMarshallingTests::PropertiesObject' do
    it 'creates an instance using #new' do
      ob = GIMarshallingTests::PropertiesObject.new
      assert_instance_of GIMarshallingTests::PropertiesObject, ob
    end

    let(:instance) { GIMarshallingTests::PropertiesObject.new }

    describe "its 'some-boolean' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-boolean').must_equal false
      end

      it 'can be retrieved with #some_boolean' do
        instance.some_boolean.must_equal false
      end

      it 'can be set with #set_property' do
        instance.set_property('some-boolean', true)
        instance.get_property('some-boolean').must_equal true
      end

      it 'can be set with #some_boolean=' do
        instance.some_boolean = true
        instance.get_property('some-boolean').must_equal true
      end
    end

    describe "its 'some-boxed-glist' property" do
      before do
        skip unless get_property_introspection_data('GIMarshallingTests',
                                                    'PropertiesObject',
                                                    'some-boxed-glist')
      end

      it 'can be retrieved with #get_property' do
        instance.get_property('some-boxed-glist').must_equal nil
      end

      it 'can be retrieved with #some_boxed_glist' do
        instance.some_boxed_glist.must_equal nil
      end

      it 'can be set with #set_property_extended' do
        instance.set_property_extended('some-boxed-glist', [1, 2, 3])
        instance.some_boxed_glist.to_a.must_equal [1, 2, 3]
      end

      it 'can be set with #some_boxed_glist=' do
        instance.some_boxed_glist = [1, 2, 3]
        instance.some_boxed_glist.to_a.must_equal [1, 2, 3]
        instance.get_property_extended('some-boxed-glist').to_a.must_equal [1, 2, 3]
      end
    end

    describe "its 'some-boxed-struct' property" do
      before do
        skip unless get_property_introspection_data('GIMarshallingTests',
                                                    'PropertiesObject',
                                                    'some-boxed-struct')
      end

      it 'can be retrieved with #get_property' do
        instance.get_property('some-boxed-struct').must_equal nil
      end

      it 'can be retrieved with #some_boxed_struct' do
        instance.some_boxed_struct.must_equal nil
      end

      it 'can be set with #set_property' do
        boxed = GIMarshallingTests::BoxedStruct.new
        boxed.long_ = 42
        instance.set_property('some-boxed-struct', boxed)
        instance.get_property('some-boxed-struct').long_.must_equal 42
      end

      it 'can be set with #some_boxed_struct=' do
        boxed = GIMarshallingTests::BoxedStruct.new
        boxed.long_ = 43
        instance.some_boxed_struct = boxed
        instance.some_boxed_struct.long_.must_equal 43
      end
    end

    describe "its 'some-char' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-char').must_equal 0
      end

      it 'can be retrieved with #some_char' do
        instance.some_char.must_equal 0
      end

      it 'can be set with #set_property' do
        instance.set_property 'some-char', 42
        instance.get_property('some-char').must_equal 42
      end

      it 'can be set with #some_char=' do
        instance.some_char = 43
        instance.some_char.must_equal 43
      end
    end

    describe "its 'some-double' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-double').must_equal 0.0
      end

      it 'can be retrieved with #some_double' do
        instance.some_double.must_equal 0.0
      end

      it 'can be set with #set_property' do
        instance.set_property('some-double', 3.14)
        instance.get_property('some-double').must_equal 3.14
      end

      it 'can be set with #some_double=' do
        instance.some_double = 3.14
        instance.some_double.must_equal 3.14
      end
    end

    describe "its 'some-float' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-float').must_equal 0.0
      end

      it 'can be retrieved with #some_float' do
        instance.some_float.must_equal 0.0
      end

      it 'can be set with #set_property' do
        instance.set_property('some-float', 3.14)
        instance.get_property('some-float').must_be_close_to 3.14
      end

      it 'can be set with #some_float=' do
        instance.some_float = 3.14
        instance.some_float.must_be_close_to 3.14
      end
    end

    describe "its 'some-int' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-int').must_equal 0
      end

      it 'can be retrieved with #some_int' do
        instance.some_int.must_equal 0
      end

      it 'can be set with #set_property' do
        instance.set_property 'some-int', 4242
        instance.get_property('some-int').must_equal 4242
      end

      it 'can be set with #some_int=' do
        instance.some_int = 4243
        instance.some_int.must_equal 4243
      end
    end

    describe "its 'some-int64' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-int64').must_equal 0
      end

      it 'can be retrieved with #some_int64' do
        instance.some_int64.must_equal 0
      end

      it 'can be set with #set_property' do
        instance.set_property 'some-int64', 42_000_000_000_000
        instance.get_property('some-int64').must_equal 42_000_000_000_000
      end

      it 'can be set with #some_int64=' do
        instance.some_int64 = 43_000_000_000_000
        instance.some_int64.must_equal 43_000_000_000_000
      end
    end

    describe "its 'some-long' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-long').must_equal 0
      end

      it 'can be retrieved with #some_long' do
        instance.some_long.must_equal 0
      end

      it 'can be set with #set_property' do
        instance.set_property 'some-long', 4242
        instance.get_property('some-long').must_equal 4242
      end

      it 'can be set with #some_long=' do
        instance.some_long = 4243
        instance.some_long.must_equal 4243
      end
    end

    describe "its 'some-object' property" do
      before do
        skip unless get_property_introspection_data('GIMarshallingTests',
                                                    'PropertiesObject',
                                                    'some-object')
      end

      it 'can be retrieved with #get_property' do
        instance.get_property('some-object').must_be_nil
      end

      it 'can be retrieved with #some_object' do
        instance.some_object.must_be_nil
      end

      it 'can be set with #set_property' do
        ob = GIMarshallingTests::Object.new 42
        instance.set_property 'some-object', ob
        instance.get_property('some-object').must_equal ob
      end

      it 'can be set with #some_object=' do
        ob = GIMarshallingTests::Object.new 42
        instance.some_object = ob
        instance.some_object.must_equal ob
      end
    end

    describe "its 'some-strv' property" do
      before do
        skip unless get_property_introspection_data('GIMarshallingTests',
                                                    'PropertiesObject',
                                                    'some-strv')
      end

      it 'can be retrieved with #get_property' do
        instance.get_property('some-strv').must_be :==, []
      end

      it 'can be retrieved with #some_strv' do
        instance.some_strv.must_be :==, []
      end

      it 'can be set with #set_property_extended' do
        instance.set_property_extended('some-strv', %w(foo bar))
        instance.get_property('some-strv').must_be :==, %w(foo bar)
      end

      it 'can be set with #some_strv=' do
        instance.some_strv = %w(foo bar)
        instance.some_strv.must_be :==, %w(foo bar)
      end
    end

    describe "its 'some-uchar' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-uchar').must_equal 0
      end

      it 'can be retrieved with #some_uchar' do
        instance.some_uchar.must_equal 0
      end

      it 'can be set with #set_property' do
        instance.set_property 'some-uchar', 42
        instance.get_property('some-uchar').must_equal 42
      end

      it 'can be set with #some_uchar=' do
        instance.some_uchar = 43
        instance.some_uchar.must_equal 43
      end
    end

    describe "its 'some-uint' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-uint').must_equal 0
      end

      it 'can be retrieved with #some_uint' do
        instance.some_uint.must_equal 0
      end

      it 'can be set with #set_property' do
        instance.set_property 'some-uint', 4242
        instance.get_property('some-uint').must_equal 4242
      end

      it 'can be set with #some_uint=' do
        instance.some_uint = 4243
        instance.some_uint.must_equal 4243
      end
    end

    describe "its 'some-uint64' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-uint64').must_equal 0
      end

      it 'can be retrieved with #some_uint64' do
        instance.some_uint64.must_equal 0
      end

      it 'can be set with #set_property' do
        instance.set_property 'some-uint64', 42_000_000_000_000
        instance.get_property('some-uint64').must_equal 42_000_000_000_000
      end

      it 'can be set with #some_uint64=' do
        instance.some_uint64 = 43_000_000_000_000
        instance.some_uint64.must_equal 43_000_000_000_000
      end
    end

    describe "its 'some-ulong' property" do
      it 'can be retrieved with #get_property' do
        instance.get_property('some-ulong').must_equal 0
      end

      it 'can be retrieved with #some_ulong' do
        instance.some_ulong.must_equal 0
      end

      it 'can be set with #set_property' do
        instance.set_property 'some-ulong', 4242
        instance.get_property('some-ulong').must_equal 4242
      end

      it 'can be set with #some_ulong=' do
        instance.some_ulong = 4243
        instance.some_ulong.must_equal 4243
      end
    end

    describe "its 'some-variant' property" do
      before do
        skip unless get_property_introspection_data('GIMarshallingTests',
                                                    'PropertiesObject',
                                                    'some-variant')
      end

      it 'can be retrieved with #get_property' do
        instance.get_property('some-variant').must_be_nil
      end

      it 'can be retrieved with #some_variant' do
        instance.some_variant.must_be_nil
      end

      it 'can be set with #set_property' do
        value = GLib::Variant.new_string('Foo')
        instance.set_property 'some-variant', value
        instance.get_property('some-variant').must_equal value
      end

      it 'can be set with #some_variant=' do
        value = GLib::Variant.new_string('Foo')
        instance.some_variant = value
        instance.some_variant.must_equal value
      end
    end
  end

  describe 'GIMarshallingTests::SecondEnum' do
    it 'has the member :secondvalue1' do
      assert_equal 0, GIMarshallingTests::SecondEnum[:secondvalue1]
    end
    it 'has the member :secondvalue2' do
      assert_equal 1, GIMarshallingTests::SecondEnum[:secondvalue2]
    end
  end

  describe 'GIMarshallingTests::SimpleStruct' do
    it 'creates an instance using #new' do
      ss = GIMarshallingTests::SimpleStruct.new
      assert_instance_of GIMarshallingTests::SimpleStruct, ss
    end

    let(:instance) { GIMarshallingTests::SimpleStruct.new }

    it 'has a writable field long_' do
      instance.long_.must_equal 0
      instance.long_ = 1056
      instance.long_.must_equal 1056
    end

    it 'has a writable field int8' do
      instance.int8.must_equal 0
      instance.int8 = -43
      instance.int8.must_equal(-43)
    end

    it 'has a working method #inv' do
      instance.long_ = 6
      instance.int8 = 7
      instance.inv
      pass
    end

    it 'has a working method #method' do
      instance.long_ = 6
      instance.int8 = 7
      instance.method
      pass
    end

    it 'has a working function #returnv' do
      ss = GIMarshallingTests::SimpleStruct.returnv
      assert_instance_of GIMarshallingTests::SimpleStruct, ss
    end
  end

  describe 'GIMarshallingTests::SubObject' do
    it 'creates an instance using #new' do
      so = GIMarshallingTests::SubObject.new
      so.must_be_instance_of GIMarshallingTests::SubObject
      GObject.type_name(GObject.type_from_instance so).
        must_equal 'GIMarshallingTestsSubObject'
    end

    let(:instance) { GIMarshallingTests::SubObject.new }

    it 'has a working method #overwritten_method' do
      instance.overwritten_method
      pass
    end

    it 'has a working method #sub_method' do
      instance.sub_method
      pass
    end

    it 'does not have field accessors' do
      assert_raises(NoMethodError) { instance.parent_instance }
      assert_raises(NoMethodError) { instance.parent_instance = nil }
    end
  end

  describe 'GIMarshallingTests::SubSubObject' do
    it 'creates an instance using #new' do
      so = GIMarshallingTests::SubSubObject.new
      assert_instance_of GIMarshallingTests::SubSubObject, so
      GObject.type_name(GObject.type_from_instance so).
        must_equal 'GIMarshallingTestsSubSubObject'
    end

    let(:instance) { GIMarshallingTests::SubSubObject.new }

    it 'does not have field accessors' do
      assert_raises(NoMethodError) { instance.parent_instance }
      assert_raises(NoMethodError) { instance.parent_instance = nil }
    end
  end

  describe 'GIMarshallingTests::Union' do
    it 'creates an instance with #new' do
      u = GIMarshallingTests::Union.new
      assert_instance_of GIMarshallingTests::Union, u
    end

    let(:instance) { GIMarshallingTests::Union.new }

    it 'has a writable field long_' do
      assert_equal 0, instance.long_
      instance.long_ = 1056
      assert_equal 1056, instance.long_
    end

    it 'has a working method #inv' do
      instance.long_ = 42
      instance.inv
      pass
    end

    it 'has a working method #method' do
      instance.long_ = 42
      instance.method
      pass
    end

    it 'has a working function #inout' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working function #out' do
      skip 'This function is defined in the header but not implemented'
    end

    it 'has a working function #returnv' do
      u = GIMarshallingTests::Union.returnv
      assert_instance_of GIMarshallingTests::Union, u
    end
  end

  it 'has a working function #array_enum_in' do
    GIMarshallingTests.array_enum_in [:value1, :value2, :value3]
  end

  it 'has a working function #array_fixed_inout' do
    res = GIMarshallingTests.array_fixed_inout [-1, 0, 1, 2]
    res.must_be :==, [2, 1, 0, -1]
  end

  it 'has a working function #array_fixed_int_in' do
    GIMarshallingTests.array_fixed_int_in [-1, 0, 1, 2]
    pass
  end

  it 'has a working function #array_fixed_int_return' do
    res = GIMarshallingTests.array_fixed_int_return
    res.must_be :==, [-1, 0, 1, 2]
  end

  it 'has a working function #array_fixed_out' do
    res = GIMarshallingTests.array_fixed_out
    res.must_be :==, [-1, 0, 1, 2]
  end

  it 'has a working function #array_fixed_out_struct' do
    res = GIMarshallingTests.array_fixed_out_struct
    assert_equal [[7, 6], [6, 7]], res.map { |s| [s.long_, s.int8] }
  end

  it 'has a working function #array_fixed_short_in' do
    GIMarshallingTests.array_fixed_short_in [-1, 0, 1, 2]
    pass
  end

  it 'has a working function #array_fixed_short_return' do
    res = GIMarshallingTests.array_fixed_short_return
    res.must_be :==, [-1, 0, 1, 2]
  end

  it 'has a working function #array_gvariant_container_in' do
    v1 = GLib::Variant.new_int32(27)
    v2 = GLib::Variant.new_string('Hello')
    result = GIMarshallingTests.array_gvariant_container_in [v1, v2]
    arr = result.to_a
    arr.size.must_equal 2
    arr[0].get_int32.must_equal 27
    arr[1].get_string.must_equal 'Hello'
  end

  it 'has a working function #array_gvariant_full_in' do
    v1 = GLib::Variant.new_int32(27)
    v2 = GLib::Variant.new_string('Hello')
    result = GIMarshallingTests.array_gvariant_full_in [v1, v2]
    arr = result.to_a
    arr.size.must_equal 2
    arr[0].get_int32.must_equal 27
    arr[1].get_string.must_equal 'Hello'
  end

  it 'has a working function #array_gvariant_none_in' do
    v1 = GLib::Variant.new_int32(27)
    v2 = GLib::Variant.new_string('Hello')
    result = GIMarshallingTests.array_gvariant_none_in [v1, v2]
    arr = result.to_a
    arr.size.must_equal 2
    arr[0].get_int32.must_equal 27
    arr[1].get_string.must_equal 'Hello'
  end

  it 'has a working function #array_in' do
    GIMarshallingTests.array_in [-1, 0, 1, 2]
    pass
  end

  it 'has a working function #array_in_guint64_len' do
    GIMarshallingTests.array_in_guint64_len [-1, 0, 1, 2]
    pass
  end

  it 'has a working function #array_in_guint8_len' do
    GIMarshallingTests.array_in_guint8_len [-1, 0, 1, 2]
    pass
  end

  it 'has a working function #array_in_len_before' do
    GIMarshallingTests.array_in_len_before [-1, 0, 1, 2]
    pass
  end

  it 'has a working function #array_in_len_zero_terminated' do
    GIMarshallingTests.array_in_len_zero_terminated [-1, 0, 1, 2]
    pass
  end

  it 'has a working function #array_in_nonzero_nonlen' do
    skip unless get_introspection_data 'GIMarshallingTests', 'array_in_nonzero_nonlen'
    GIMarshallingTests.array_in_nonzero_nonlen 1, 'abcd'.bytes.to_a
    pass
  end

  it 'has a working function #array_in_utf8_two_in' do
    skip unless get_introspection_data 'GIMarshallingTests', 'array_in_utf8_two_in'
    GIMarshallingTests.array_in_utf8_two_in [-1, 0, 1, 2], '1', '2'
    pass
  end

  it 'has a working function #array_in_utf8_two_in_out_of_order' do
    skip unless get_introspection_data 'GIMarshallingTests', 'array_in_utf8_two_in_out_of_order'
    GIMarshallingTests.array_in_utf8_two_in_out_of_order '1', [-1, 0, 1, 2], '2'
    pass
  end

  it 'has a working function #array_inout' do
    res = GIMarshallingTests.array_inout [-1, 0, 1, 2]
    res.must_be :==, [-2, -1, 0, 1, 2]
  end

  it 'has a working function #array_inout_etc' do
    arr, sum = GIMarshallingTests.array_inout_etc 42, [-1, 0, 1, 2], 24
    arr.must_be :==, [42, -1, 0, 1, 24]
    sum.must_equal 42 + 24
  end

  it 'has a working function #array_out' do
    res = GIMarshallingTests.array_out
    res.must_be :==, [-1, 0, 1, 2]
  end

  it 'has a working function #array_out_etc' do
    arr, sum = GIMarshallingTests.array_out_etc 42, 24
    arr.must_be :==, [42, 0, 1, 24]
    sum.must_equal 42 + 24
  end

  it 'has a working function #array_return' do
    res = GIMarshallingTests.array_return
    res.must_be :==, [-1, 0, 1, 2]
  end

  it 'has a working function #array_return_etc' do
    arr, sum = GIMarshallingTests.array_return_etc 42, 24
    arr.must_be :==, [42, 0, 1, 24]
    sum.must_equal 42 + 24
  end

  it 'has a working function #array_simple_struct_in' do
    arr = [1, 2, 3].map do |val|
      GIMarshallingTests::SimpleStruct.new.tap { |struct| struct.long_ = val }
    end
    GIMarshallingTests.array_simple_struct_in arr
  end

  it 'has a working function #array_string_in' do
    GIMarshallingTests.array_string_in %w(foo bar)
    pass
  end

  it 'has a working function #array_struct_in' do
    arr = [1, 2, 3].map do |val|
      GIMarshallingTests::BoxedStruct.new.tap { |struct| struct.long_ = val }
    end
    GIMarshallingTests.array_struct_in arr
  end

  # NOTE: Should be run with valgrind. See gimarhallingtests.c.
  it 'has a working function #array_struct_take_in' do
    arr = [1, 2, 3].map do |val|
      GIMarshallingTests::BoxedStruct.new.tap { |struct| struct.long_ = val }
    end
    GIMarshallingTests.array_struct_take_in arr
  end

  it 'has a working function #array_struct_value_in' do
    skip unless get_introspection_data 'GIMarshallingTests', 'array_struct_value_in'
    arr = [1, 2, 3].map do |val|
      GIMarshallingTests::BoxedStruct.new.tap { |struct| struct.long_ = val }
    end
    GIMarshallingTests.array_struct_value_in arr
  end

  it 'has a working function #array_uint8_in' do
    arr = 'abcd'.bytes.to_a
    GIMarshallingTests.array_uint8_in arr
    pass
  end

  it 'has a working function #array_zero_terminated_in' do
    GIMarshallingTests.array_zero_terminated_in %w(0 1 2)
    pass
  end

  it 'has a working function #array_zero_terminated_inout' do
    res = GIMarshallingTests.array_zero_terminated_inout %w(0 1 2)
    res.must_be :==, ['-1', '0', '1', '2']
  end

  it 'has a working function #array_zero_terminated_out' do
    res = GIMarshallingTests.array_zero_terminated_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #array_zero_terminated_return' do
    res = GIMarshallingTests.array_zero_terminated_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #array_zero_terminated_return_null' do
    res = GIMarshallingTests.array_zero_terminated_return_null
    res.must_be :==, []
  end

  it 'has a working function #array_zero_terminated_return_struct' do
    res = GIMarshallingTests.array_zero_terminated_return_struct
    res.to_a.map(&:long_).must_equal [42, 43, 44]
  end

  it 'has a working function #boolean_in_false' do
    GIMarshallingTests.boolean_in_false false
    pass
  end

  it 'has a working function #boolean_in_true' do
    GIMarshallingTests.boolean_in_true true
    pass
  end

  it 'has a working function #boolean_inout_false_true' do
    res = GIMarshallingTests.boolean_inout_false_true false
    assert_equal true, res
  end

  it 'has a working function #boolean_inout_true_false' do
    res = GIMarshallingTests.boolean_inout_true_false true
    assert_equal false, res
  end

  it 'has a working function #boolean_out_false' do
    res = GIMarshallingTests.boolean_out_false
    assert_equal false, res
  end

  it 'has a working function #boolean_out_true' do
    res = GIMarshallingTests.boolean_out_true
    assert_equal true, res
  end

  it 'has a working function #boolean_return_false' do
    res = GIMarshallingTests.boolean_return_false
    assert_equal false, res
  end

  it 'has a working function #boolean_return_true' do
    res = GIMarshallingTests.boolean_return_true
    assert_equal true, res
  end

  it 'has a working function #boxed_struct_inout' do
    bx = GIMarshallingTests::BoxedStruct.new
    bx.long_ = 42
    res = GIMarshallingTests.boxed_struct_inout bx
    assert_equal 0, res.long_
  end

  it 'has a working function #boxed_struct_out' do
    res = GIMarshallingTests.boxed_struct_out
    assert_equal 42, res.long_
  end

  it 'has a working function #boxed_struct_returnv' do
    res = GIMarshallingTests.boxed_struct_returnv
    assert_equal 42, res.long_
    res.g_strv.must_be :==, %w(0 1 2)
  end

  it 'has a working function #bytearray_full_return' do
    ret = GIMarshallingTests.bytearray_full_return
    assert_instance_of GLib::ByteArray, ret
    assert_includes(
      ['0123'.bytes.to_a, "\x001\xFF3".bytes.to_a],
      ret.to_string.bytes.to_a)
  end

  it 'has a working function #bytearray_none_in' do
    val = GIMarshallingTests.bytearray_full_return.to_string
    ba = GLib::ByteArray.new
    ba = ba.append val
    GIMarshallingTests.bytearray_none_in ba
    pass
  end

  it 'has a working function #callback_multiple_out_parameters' do
    result = GIMarshallingTests.callback_multiple_out_parameters proc { |*_args|
      [12.0, 13.0]
    }
    result.must_equal [12.0, 13.0]
  end

  it 'has a working function #callback_one_out_parameter' do
    result = GIMarshallingTests.callback_one_out_parameter proc { 42.0 }
    result.must_equal 42.0
  end

  it 'has a working function #callback_owned_boxed' do
    skip unless get_introspection_data 'GIMarshallingTests', 'callback_owned_boxed'
    a = nil

    callback = proc { |box, callback_data| a = box.long_ + callback_data }

    result = GIMarshallingTests.callback_owned_boxed callback, 42
    result.must_equal 1
    a.must_equal 43

    result = GIMarshallingTests.callback_owned_boxed callback, 42
    result.must_equal 2
    a.must_equal 44
  end

  it 'has a working function #callback_return_value_and_multiple_out_parameters' do
    result = GIMarshallingTests.callback_return_value_and_multiple_out_parameters proc { |*_args|
      [42, -142, 3]
    }
    result.must_equal [42, -142, 3]
  end

  it 'has a working function #callback_return_value_and_one_out_parameter' do
    result = GIMarshallingTests.callback_return_value_and_one_out_parameter proc { |*_args|
      [42, -142]
    }
    result.must_equal [42, -142]
  end

  it 'has a working function #callback_return_value_only' do
    result = GIMarshallingTests.callback_return_value_only proc { 42 }
    result.must_equal 42
  end

  it 'has a working function #double_in' do
    GIMarshallingTests.double_in Float::MAX
    pass
  end

  it 'has a working function #double_inout' do
    ret = GIMarshallingTests.double_inout Float::MAX
    assert_in_epsilon 2.225e-308, ret
  end

  it 'has a working function #double_out' do
    ret = GIMarshallingTests.double_out
    assert_equal Float::MAX, ret
  end

  it 'has a working function #double_return' do
    ret = GIMarshallingTests.double_return
    assert_equal Float::MAX, ret
  end

  it 'has a working function #enum_in' do
    GIMarshallingTests.enum_in :value3
    pass
  end

  it 'has a working function #enum_inout' do
    e = GIMarshallingTests.enum_inout :value3
    assert_equal :value1, e
  end

  it 'has a working function #enum_out' do
    e = GIMarshallingTests.enum_out
    assert_equal :value3, e
  end

  it 'has a working function #enum_returnv' do
    e = GIMarshallingTests.enum_returnv
    assert_equal :value3, e
  end

  it 'has a working function #filename_list_return' do
    fl = GIMarshallingTests.filename_list_return
    assert_equal nil, fl
  end

  it 'has a working function #flags_in' do
    GIMarshallingTests.flags_in :value2
    pass
  end

  it 'has a working function #flags_in_zero' do
    GIMarshallingTests.flags_in_zero 0
    pass
  end

  it 'has a working function #flags_inout' do
    res = GIMarshallingTests.flags_inout :value2
    assert_equal :value1, res
  end

  it 'has a working function #flags_out' do
    res = GIMarshallingTests.flags_out
    assert_equal :value2, res
  end

  it 'has a working function #flags_returnv' do
    res = GIMarshallingTests.flags_returnv
    assert_equal :value2, res
  end

  it 'has a working function #float_in' do
    # float_return returns MAX_FLT
    flt = GIMarshallingTests.float_return
    GIMarshallingTests.float_in flt
    pass
  end

  it 'has a working function #float_inout' do
    # float_return returns MAX_FLT
    flt = GIMarshallingTests.float_return
    res = GIMarshallingTests.float_inout flt
    assert_in_epsilon 1.175e-38, res
  end

  it 'has a working function #float_out' do
    flt = GIMarshallingTests.float_out
    assert_in_epsilon 3.402e+38, flt
  end

  it 'has a working function #float_return' do
    flt = GIMarshallingTests.float_return
    assert_in_epsilon 3.402e+38, flt
  end

  it 'has a working function #garray_int_none_in' do
    arr = [-1, 0, 1, 2]
    GIMarshallingTests.garray_int_none_in arr
    pass
  end

  it 'has a working function #garray_int_none_return' do
    arr = GIMarshallingTests.garray_int_none_return
    arr.must_be :==, [-1, 0, 1, 2]
  end

  it 'has a working function #garray_uint64_none_in' do
    skip unless get_introspection_data 'GIMarshallingTests', 'garray_uint64_none_in'
    GIMarshallingTests.garray_uint64_none_in [0, 0xffff_ffff_ffff_ffff]
    pass
  end

  it 'has a working function #garray_uint64_none_return' do
    skip unless get_introspection_data 'GIMarshallingTests', 'garray_uint64_none_return'
    res = GIMarshallingTests.garray_uint64_none_return
    res.must_be :==, [0, 0xffff_ffff_ffff_ffff]
  end

  it 'has a working function #garray_utf8_container_inout' do
    res = GIMarshallingTests.garray_utf8_container_inout %w(0 1 2)
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #garray_utf8_container_out' do
    res = GIMarshallingTests.garray_utf8_container_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #garray_utf8_container_return' do
    res = GIMarshallingTests.garray_utf8_container_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #garray_utf8_full_inout' do
    arr = %w(0 1 2)
    res = GIMarshallingTests.garray_utf8_full_inout arr
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #garray_utf8_full_out' do
    res = GIMarshallingTests.garray_utf8_full_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #garray_utf8_full_out_caller_allocated' do
    skip unless get_introspection_data 'GIMarshallingTests',
                                       'garray_utf8_full_out_caller_allocated'
    res = GIMarshallingTests.garray_utf8_full_out_caller_allocated
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #garray_utf8_full_return' do
    res = GIMarshallingTests.garray_utf8_full_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #garray_utf8_none_in' do
    arr = %w(0 1 2)
    GIMarshallingTests.garray_utf8_none_in arr
    pass
  end

  it 'has a working function #garray_utf8_none_inout' do
    arr = %w(0 1 2)
    res = GIMarshallingTests.garray_utf8_none_inout arr
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #garray_utf8_none_out' do
    res = GIMarshallingTests.garray_utf8_none_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #garray_utf8_none_return' do
    res = GIMarshallingTests.garray_utf8_none_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gbytes_full_return' do
    skip unless get_introspection_data 'GIMarshallingTests', 'gbytes_full_return'
    res = GIMarshallingTests.gbytes_full_return
    res.to_a.must_equal [0, 49, 0xFF, 51]
  end

  it 'has a working function #gbytes_none_in' do
    skip unless get_introspection_data 'GIMarshallingTests', 'gbytes_none_in'
    GIMarshallingTests.gbytes_none_in [0, 49, 0xFF, 51]
    pass
  end

  it 'has a working function #gclosure_in' do
    cl = GObject::RubyClosure.new { 42 }
    GIMarshallingTests.gclosure_in cl
    pass
  end

  it 'has a working function #gclosure_return' do
    cl = GIMarshallingTests.gclosure_return
    gv = GObject::Value.wrap_ruby_value 0
    cl.invoke gv, nil, nil
    assert_equal 42, gv.get_value
  end

  it 'has a working function #genum_in' do
    GIMarshallingTests.genum_in :value3
    pass
  end

  it 'has a working function #genum_inout' do
    res = GIMarshallingTests.genum_inout :value3
    assert_equal :value1, res
  end

  it 'has a working function #genum_out' do
    res = GIMarshallingTests.genum_out
    assert_equal :value3, res
  end

  it 'has a working function #genum_returnv' do
    res = GIMarshallingTests.genum_returnv
    assert_equal :value3, res
  end

  it 'has a working function #gerror' do
    begin
      GIMarshallingTests.gerror
      flunk 'Error should have been raised'
    rescue GirFFI::GLibError => e
      e.message.must_equal GIMarshallingTests::CONSTANT_GERROR_MESSAGE
      e.domain.must_equal GIMarshallingTests::CONSTANT_GERROR_DOMAIN
      e.code.must_equal GIMarshallingTests::CONSTANT_GERROR_CODE
    end
  end

  it 'has a working function #gerror_array_in' do
    begin
      GIMarshallingTests.gerror_array_in [1, 2, 3]
      flunk 'Error should have been raised'
    rescue GirFFI::GLibError => e
      e.message.must_equal GIMarshallingTests::CONSTANT_GERROR_MESSAGE
      e.domain.must_equal GIMarshallingTests::CONSTANT_GERROR_DOMAIN
      e.code.must_equal GIMarshallingTests::CONSTANT_GERROR_CODE
    end
  end

  it 'has a working function #gerror_out' do
    error, debug = GIMarshallingTests.gerror_out
    debug.must_equal GIMarshallingTests::CONSTANT_GERROR_DEBUG_MESSAGE
    error.message.must_equal GIMarshallingTests::CONSTANT_GERROR_MESSAGE
  end

  it 'has a working function #gerror_out_transfer_none' do
    error, debug = GIMarshallingTests.gerror_out_transfer_none
    debug.must_equal GIMarshallingTests::CONSTANT_GERROR_DEBUG_MESSAGE
    error.message.must_equal GIMarshallingTests::CONSTANT_GERROR_MESSAGE
  end

  it 'has a working function #gerror_return' do
    error = GIMarshallingTests.gerror_return
    error.message.must_equal GIMarshallingTests::CONSTANT_GERROR_MESSAGE
  end

  it 'has a working function #ghashtable_int_none_in' do
    GIMarshallingTests.ghashtable_int_none_in(
      -1 => 1, 0 => 0, 1 => -1, 2 => -2)
  end

  it 'has a working function #ghashtable_int_none_return' do
    gh = GIMarshallingTests.ghashtable_int_none_return
    assert_equal({ -1 => 1, 0 => 0, 1 => -1, 2 => -2 }, gh.to_hash)
  end

  it 'has a working function #ghashtable_utf8_container_in' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #ghashtable_utf8_container_inout' do
    hsh = { '-1' => '1', '0' => '0', '1' => '-1', '2' => '-2' }
    res = GIMarshallingTests.ghashtable_utf8_container_inout hsh
    assert_equal({ '-1' => '1', '0' => '0', '1' => '1' }, res.to_hash)
  end

  it 'has a working function #ghashtable_utf8_container_out' do
    res = GIMarshallingTests.ghashtable_utf8_container_out
    assert_equal({ '-1' => '1', '0' => '0', '1' => '-1', '2' => '-2' },
                 res.to_hash)
  end

  it 'has a working function #ghashtable_utf8_container_return' do
    res = GIMarshallingTests.ghashtable_utf8_container_return
    assert_equal({ '-1' => '1', '0' => '0', '1' => '-1', '2' => '-2' },
                 res.to_hash)
  end

  it 'has a working function #ghashtable_utf8_full_in' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #ghashtable_utf8_full_inout' do
    hsh = { '-1' => '1', '0' => '0', '1' => '-1', '2' => '-2' }
    res = GIMarshallingTests.ghashtable_utf8_full_inout hsh
    assert_equal({ '-1' => '1', '0' => '0', '1' => '1' }, res.to_hash)
  end

  it 'has a working function #ghashtable_utf8_full_out' do
    res = GIMarshallingTests.ghashtable_utf8_full_out
    assert_equal({ '-1' => '1', '0' => '0', '1' => '-1', '2' => '-2' },
                 res.to_hash)
  end

  it 'has a working function #ghashtable_utf8_full_return' do
    res = GIMarshallingTests.ghashtable_utf8_full_return
    assert_equal({ '-1' => '1', '0' => '0', '1' => '-1', '2' => '-2' },
                 res.to_hash)
  end

  it 'has a working function #ghashtable_utf8_none_in' do
    hsh = { '-1' => '1', '0' => '0', '1' => '-1', '2' => '-2' }
    GIMarshallingTests.ghashtable_utf8_none_in hsh
    pass
  end

  it 'has a working function #ghashtable_utf8_none_inout' do
    hsh = { '-1' => '1', '0' => '0', '1' => '-1', '2' => '-2' }
    res = GIMarshallingTests.ghashtable_utf8_none_inout hsh
    assert_equal({ '-1' => '1', '0' => '0', '1' => '1' }, res.to_hash)
  end

  it 'has a working function #ghashtable_utf8_none_out' do
    res = GIMarshallingTests.ghashtable_utf8_none_out
    assert_equal({ '-1' => '1', '0' => '0', '1' => '-1', '2' => '-2' },
                 res.to_hash)
  end

  it 'has a working function #ghashtable_utf8_none_return' do
    res = GIMarshallingTests.ghashtable_utf8_none_return
    assert_equal({ '-1' => '1', '0' => '0', '1' => '-1', '2' => '-2' },
                 res.to_hash)
  end

  it 'has a working function #glist_int_none_in' do
    GIMarshallingTests.glist_int_none_in [-1, 0, 1, 2]
    pass
  end

  it 'has a working function #glist_int_none_return' do
    res = GIMarshallingTests.glist_int_none_return
    res.must_be :==, [-1, 0, 1, 2]
  end

  it 'has a working function #glist_uint32_none_in' do
    skip unless get_introspection_data 'GIMarshallingTests', 'glist_uint32_none_in'
    GIMarshallingTests.glist_uint32_none_in [0, 0xffff_ffff]
    pass
  end

  it 'has a working function #glist_uint32_none_return' do
    skip unless get_introspection_data 'GIMarshallingTests', 'glist_uint32_none_return'
    res = GIMarshallingTests.glist_uint32_none_return
    res.must_be :==, [0, 0xffff_ffff]
  end

  it 'has a working function #glist_utf8_container_inout' do
    res = GIMarshallingTests.glist_utf8_container_inout %w(0 1 2)
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #glist_utf8_container_out' do
    res = GIMarshallingTests.glist_utf8_container_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #glist_utf8_container_return' do
    res = GIMarshallingTests.glist_utf8_container_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #glist_utf8_full_inout' do
    res = GIMarshallingTests.glist_utf8_full_inout %w(0 1 2)
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #glist_utf8_full_out' do
    res = GIMarshallingTests.glist_utf8_full_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #glist_utf8_full_return' do
    res = GIMarshallingTests.glist_utf8_full_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #glist_utf8_none_in' do
    GIMarshallingTests.glist_utf8_none_in %w(0 1 2)
  end

  it 'has a working function #glist_utf8_none_inout' do
    res = GIMarshallingTests.glist_utf8_none_inout %w(0 1 2)
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #glist_utf8_none_out' do
    res = GIMarshallingTests.glist_utf8_none_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #glist_utf8_none_return' do
    res = GIMarshallingTests.glist_utf8_none_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gptrarray_utf8_container_inout' do
    res = GIMarshallingTests.gptrarray_utf8_container_inout %w(0 1 2)
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #gptrarray_utf8_container_out' do
    res = GIMarshallingTests.gptrarray_utf8_container_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gptrarray_utf8_container_return' do
    res = GIMarshallingTests.gptrarray_utf8_container_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gptrarray_utf8_full_inout' do
    res = GIMarshallingTests.gptrarray_utf8_full_inout %w(0 1 2)
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #gptrarray_utf8_full_out' do
    res = GIMarshallingTests.gptrarray_utf8_full_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gptrarray_utf8_full_return' do
    res = GIMarshallingTests.gptrarray_utf8_full_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gptrarray_utf8_none_in' do
    GIMarshallingTests.gptrarray_utf8_none_in %w(0 1 2)
  end

  it 'has a working function #gptrarray_utf8_none_inout' do
    res = GIMarshallingTests.gptrarray_utf8_none_inout %w(0 1 2)
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #gptrarray_utf8_none_out' do
    res = GIMarshallingTests.gptrarray_utf8_none_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gptrarray_utf8_none_return' do
    res = GIMarshallingTests.gptrarray_utf8_none_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gslist_int_none_in' do
    GIMarshallingTests.gslist_int_none_in [-1, 0, 1, 2]
    pass
  end

  it 'has a working function #gslist_int_none_return' do
    res = GIMarshallingTests.gslist_int_none_return
    res.must_be :==, [-1, 0, 1, 2]
  end

  it 'has a working function #gslist_utf8_container_inout' do
    res = GIMarshallingTests.gslist_utf8_container_inout %w(0 1 2)
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #gslist_utf8_container_out' do
    res = GIMarshallingTests.gslist_utf8_container_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gslist_utf8_container_return' do
    res = GIMarshallingTests.gslist_utf8_container_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gslist_utf8_full_inout' do
    res = GIMarshallingTests.gslist_utf8_full_inout %w(0 1 2)
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #gslist_utf8_full_out' do
    res = GIMarshallingTests.gslist_utf8_full_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gslist_utf8_full_return' do
    res = GIMarshallingTests.gslist_utf8_full_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gslist_utf8_none_in' do
    GIMarshallingTests.gslist_utf8_none_in %w(0 1 2)
    pass
  end

  it 'has a working function #gslist_utf8_none_inout' do
    res = GIMarshallingTests.gslist_utf8_none_inout %w(0 1 2)
    res.must_be :==, ['-2', '-1', '0', '1']
  end

  it 'has a working function #gslist_utf8_none_out' do
    res = GIMarshallingTests.gslist_utf8_none_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gslist_utf8_none_return' do
    res = GIMarshallingTests.gslist_utf8_none_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gstrv_in' do
    GIMarshallingTests.gstrv_in %w(0 1 2)
    pass
  end

  it 'has a working function #gstrv_inout' do
    res = GIMarshallingTests.gstrv_inout %w(0 1 2)
    res.must_be :==, ['-1', '0', '1', '2']
  end

  it 'has a working function #gstrv_out' do
    res = GIMarshallingTests.gstrv_out
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gstrv_return' do
    res = GIMarshallingTests.gstrv_return
    res.must_be :==, %w(0 1 2)
  end

  it 'has a working function #gtype_in' do
    GIMarshallingTests.gtype_in GObject::TYPE_NONE
    pass
  end

  it 'has a working function #gtype_inout' do
    res = GIMarshallingTests.gtype_inout GObject::TYPE_NONE
    res.must_equal GObject::TYPE_INT
  end

  it 'has a working function #gtype_out' do
    res = GIMarshallingTests.gtype_out
    res.must_equal GObject::TYPE_NONE
  end

  it 'has a working function #gtype_return' do
    res = GIMarshallingTests.gtype_return
    res.must_equal GObject::TYPE_NONE
  end

  it 'has a working function #gtype_string_in' do
    GIMarshallingTests.gtype_string_in GObject::TYPE_STRING
    pass
  end

  it 'has a working function #gtype_string_out' do
    res = GIMarshallingTests.gtype_string_out
    res.must_equal GObject::TYPE_STRING
  end

  it 'has a working function #gtype_string_return' do
    res = GIMarshallingTests.gtype_string_return
    res.must_equal GObject::TYPE_STRING
  end

  it 'has a working function #gvalue_flat_array' do
    GIMarshallingTests.gvalue_flat_array [42, '42', true]
    pass
  end

  it 'has a working function #gvalue_flat_array_round_trip' do
    result = GIMarshallingTests.gvalue_flat_array_round_trip 42, '42', true
    arr = result.to_a
    arr[0].get_value.must_equal 42
    arr[1].get_value.must_equal '42'
    arr[2].get_value.must_equal true
  end

  it 'has a working function #gvalue_in' do
    GIMarshallingTests.gvalue_in GObject::Value.wrap_ruby_value(42)
    GIMarshallingTests.gvalue_in 42
    pass
  end

  it 'has a working function #gvalue_in_enum' do
    gv = GObject::Value.new
    gv.init GIMarshallingTests::GEnum.gtype
    gv.set_enum GIMarshallingTests::GEnum[:value3]
    GIMarshallingTests.gvalue_in_enum gv
    pass
  end

  it 'has a working function #gvalue_in_with_modification' do
    skip unless get_introspection_data 'GIMarshallingTests', 'gvalue_in_with_modification'
    gv = GObject::Value.wrap_ruby_value(42)
    GIMarshallingTests.gvalue_in_with_modification gv
    gv.get_value.must_equal 24
  end

  it 'has a working function #gvalue_in_with_type' do
    gv = GObject::Value.new
    gv.init GIMarshallingTests::SubSubObject.gtype
    GIMarshallingTests.gvalue_in_with_type gv, GIMarshallingTests::Object.gtype
  end

  it 'has a working function #gvalue_inout' do
    res = GIMarshallingTests.gvalue_inout GObject::Value.wrap_ruby_value(42)
    assert_equal '42', res

    res = GIMarshallingTests.gvalue_inout 42
    assert_equal '42', res
  end

  it 'has a working function #gvalue_int64_in' do
    skip unless get_introspection_data 'GIMarshallingTests', 'gvalue_int64_in'
    gv = GObject::Value.new
    gv.init GObject::TYPE_INT64
    gv.set_value 0x7fff_ffff_ffff_ffff
    GIMarshallingTests.gvalue_int64_in gv
    pass
  end

  it 'has a working function #gvalue_int64_out' do
    skip unless get_introspection_data 'GIMarshallingTests', 'gvalue_int64_out'
    gv = GIMarshallingTests.gvalue_int64_out
    gv.must_equal 0x7fff_ffff_ffff_ffff
  end

  it 'has a working function #gvalue_out' do
    res = GIMarshallingTests.gvalue_out
    assert_equal 42, res
  end

  it 'has a working function #gvalue_out_caller_allocates' do
    skip unless get_introspection_data 'GIMarshallingTests', 'gvalue_out_caller_allocates'
    res = GIMarshallingTests.gvalue_out_caller_allocates
    res.must_equal 42
  end

  it 'has a working function #gvalue_return' do
    res = GIMarshallingTests.gvalue_return
    res.must_equal 42
  end

  it 'has a working function #init_function' do
    res, arr = GIMarshallingTests.init_function %w(foo bar baz)
    res.must_equal true
    arr.must_be :==, %w(foo bar)
  end

  it 'has a working function #int16_in_max' do
    GIMarshallingTests.int16_in_max 0x7fff
    pass
  end

  it 'has a working function #int16_in_min' do
    GIMarshallingTests.int16_in_min(-0x8000)
    pass
  end

  it 'has a working function #int16_inout_max_min' do
    res = GIMarshallingTests.int16_inout_max_min 0x7fff
    assert_equal res, -0x8000
  end

  it 'has a working function #int16_inout_min_max' do
    res = GIMarshallingTests.int16_inout_min_max(-0x8000)
    assert_equal 0x7fff, res
  end

  it 'has a working function #int16_out_max' do
    res = GIMarshallingTests.int16_out_max
    assert_equal 0x7fff, res
  end

  it 'has a working function #int16_out_min' do
    res = GIMarshallingTests.int16_out_min
    assert_equal(-0x8000, res)
  end

  it 'has a working function #int16_return_max' do
    res = GIMarshallingTests.int16_return_max
    assert_equal 0x7fff, res
  end

  it 'has a working function #int16_return_min' do
    res = GIMarshallingTests.int16_return_min
    assert_equal(-0x8000, res)
  end

  it 'has a working function #int32_in_max' do
    GIMarshallingTests.int32_in_max 0x7fffffff
    pass
  end

  it 'has a working function #int32_in_min' do
    GIMarshallingTests.int32_in_min(-0x80000000)
    pass
  end

  it 'has a working function #int32_inout_max_min' do
    res = GIMarshallingTests.int32_inout_max_min 0x7fffffff
    assert_equal(-0x80000000, res)
  end

  it 'has a working function #int32_inout_min_max' do
    res = GIMarshallingTests.int32_inout_min_max(-0x80000000)
    assert_equal 0x7fffffff, res
  end

  it 'has a working function #int32_out_max' do
    res = GIMarshallingTests.int32_out_max
    assert_equal 0x7fffffff, res
  end

  it 'has a working function #int32_out_min' do
    res = GIMarshallingTests.int32_out_min
    assert_equal(-0x80000000, res)
  end

  it 'has a working function #int32_return_max' do
    res = GIMarshallingTests.int32_return_max
    assert_equal 0x7fffffff, res
  end

  it 'has a working function #int32_return_min' do
    res = GIMarshallingTests.int32_return_min
    assert_equal(-0x80000000, res)
  end

  it 'has a working function #int64_in_max' do
    GIMarshallingTests.int64_in_max 0x7fffffffffffffff
    pass
  end

  it 'has a working function #int64_in_min' do
    GIMarshallingTests.int64_in_min(-0x8000000000000000)
    pass
  end

  it 'has a working function #int64_inout_max_min' do
    res = GIMarshallingTests.int64_inout_max_min 0x7fffffffffffffff
    assert_equal(-0x8000000000000000, res)
  end

  it 'has a working function #int64_inout_min_max' do
    res = GIMarshallingTests.int64_inout_min_max(-0x8000000000000000)
    assert_equal 0x7fffffffffffffff, res
  end

  it 'has a working function #int64_out_max' do
    res = GIMarshallingTests.int64_out_max
    assert_equal 0x7fffffffffffffff, res
  end

  it 'has a working function #int64_out_min' do
    res = GIMarshallingTests.int64_out_min
    assert_equal(-0x8000000000000000, res)
  end

  it 'has a working function #int64_return_max' do
    res = GIMarshallingTests.int64_return_max
    assert_equal 0x7fffffffffffffff, res
  end

  it 'has a working function #int64_return_min' do
    res = GIMarshallingTests.int64_return_min
    assert_equal(-0x8000000000000000, res)
  end

  it 'has a working function #int8_in_max' do
    GIMarshallingTests.int8_in_max 0x7f
    pass
  end

  it 'has a working function #int8_in_min' do
    GIMarshallingTests.int8_in_min(-0x80)
    pass
  end

  it 'has a working function #int8_inout_max_min' do
    res = GIMarshallingTests.int8_inout_max_min 0x7f
    assert_equal(-0x80, res)
  end

  it 'has a working function #int8_inout_min_max' do
    res = GIMarshallingTests.int8_inout_min_max(-0x80)
    assert_equal 0x7f, res
  end

  it 'has a working function #int8_out_max' do
    res = GIMarshallingTests.int8_out_max
    assert_equal 0x7f, res
  end

  it 'has a working function #int8_out_min' do
    res = GIMarshallingTests.int8_out_min
    assert_equal(-0x80, res)
  end

  it 'has a working function #int8_return_max' do
    res = GIMarshallingTests.int8_return_max
    assert_equal 0x7f, res
  end

  it 'has a working function #int8_return_min' do
    res = GIMarshallingTests.int8_return_min
    assert_equal(-0x80, res)
  end

  it 'has a working function #int_in_max' do
    GIMarshallingTests.int_in_max 0x7fffffff
    pass
  end

  it 'has a working function #int_in_min' do
    GIMarshallingTests.int_in_min(-0x80000000)
    pass
  end

  it 'has a working function #int_inout_max_min' do
    res = GIMarshallingTests.int_inout_max_min 0x7fffffff
    assert_equal(-0x80000000, res)
  end

  it 'has a working function #int_inout_min_max' do
    res = GIMarshallingTests.int_inout_min_max(-0x80000000)
    assert_equal 0x7fffffff, res
  end

  it 'has a working function #int_one_in_utf8_two_in_one_allows_none' do
    skip unless get_introspection_data('GIMarshallingTests',
                                       'int_one_in_utf8_two_in_one_allows_none')
    GIMarshallingTests.int_one_in_utf8_two_in_one_allows_none 1, '2', '3'
    GIMarshallingTests.int_one_in_utf8_two_in_one_allows_none 1, nil, '3'
    pass
  end

  it 'has a working function #int_out_max' do
    res = GIMarshallingTests.int_out_max
    assert_equal 0x7fffffff, res
  end

  it 'has a working function #int_out_min' do
    res = GIMarshallingTests.int_out_min
    assert_equal(-0x80000000, res)
  end

  it 'has a working function #int_out_out' do
    res = GIMarshallingTests.int_out_out
    assert_equal [6, 7], res
  end

  it 'has a working function #int_return_max' do
    res = GIMarshallingTests.int_return_max
    assert_equal 0x7fffffff, res
  end

  it 'has a working function #int_return_min' do
    res = GIMarshallingTests.int_return_min
    assert_equal(-0x80000000, res)
  end

  it 'has a working function #int_return_out' do
    res = GIMarshallingTests.int_return_out
    assert_equal [6, 7], res
  end

  it 'has a working function #int_three_in_three_out' do
    res = GIMarshallingTests.int_three_in_three_out 4, 5, 6
    assert_equal [4, 5, 6], res
  end

  it 'has a working function #int_two_in_utf8_two_in_with_allow_none' do
    skip unless get_introspection_data('GIMarshallingTests',
                                       'int_two_in_utf8_two_in_with_allow_none')
    GIMarshallingTests.int_two_in_utf8_two_in_with_allow_none 1, 2, '3', '4'
    GIMarshallingTests.int_two_in_utf8_two_in_with_allow_none 1, 2, nil, nil
    pass
  end

  it 'has a working function #long_in_max' do
    GIMarshallingTests.long_in_max max_long
    pass
  end

  it 'has a working function #long_in_min' do
    GIMarshallingTests.long_in_min min_long
    pass
  end

  it 'has a working function #long_inout_max_min' do
    res = GIMarshallingTests.long_inout_max_min max_long
    assert_equal min_long, res
  end

  it 'has a working function #long_inout_min_max' do
    res = GIMarshallingTests.long_inout_min_max min_long
    assert_equal max_long, res
  end

  it 'has a working function #long_out_max' do
    res = GIMarshallingTests.long_out_max
    assert_equal max_long, res
  end

  it 'has a working function #long_out_min' do
    res = GIMarshallingTests.long_out_min
    assert_equal min_long, res
  end

  it 'has a working function #long_return_max' do
    res = GIMarshallingTests.long_return_max
    assert_equal max_long, res
  end

  it 'has a working function #long_return_min' do
    res = GIMarshallingTests.long_return_min
    assert_equal min_long, res
  end

  it 'has a working function #multi_array_key_value_in' do
    keys = %w(one two three)
    values = [1, 2, 3].map { |val| GObject::Value.wrap_ruby_value val }
    GIMarshallingTests.multi_array_key_value_in keys, values
  end

  it 'has a working function #no_type_flags_in' do
    GIMarshallingTests.no_type_flags_in :value2
    pass
  end

  it 'has a working function #no_type_flags_in_zero' do
    GIMarshallingTests.no_type_flags_in_zero 0
    pass
  end

  it 'has a working function #no_type_flags_inout' do
    res = GIMarshallingTests.no_type_flags_inout :value2
    assert_equal :value1, res
  end

  it 'has a working function #no_type_flags_out' do
    res = GIMarshallingTests.no_type_flags_out
    assert_equal :value2, res
  end

  it 'has a working function #no_type_flags_returnv' do
    res = GIMarshallingTests.no_type_flags_returnv
    assert_equal :value2, res
  end

  it 'has a working function #overrides_struct_returnv' do
    res = GIMarshallingTests.overrides_struct_returnv
    res.must_be_instance_of GIMarshallingTests::OverridesStruct
  end

  # TODO: Wait for fixed version of param_spec_in_bool to land in Debian/Ubuntu
  # See https://bugzilla.gnome.org/show_bug.cgi?id=728409
  it 'has a working function #param_spec_in_bool' do
    skip 'param_spec_in_bool tests the wrong type'
    ps = GObject.param_spec_boolean 'mybool', 'nick', 'blurb', true, :readable
    GIMarshallingTests.param_spec_in_bool ps
  end

  it 'has a working function #param_spec_out' do
    skip unless get_introspection_data 'GIMarshallingTests', 'param_spec_out'
    res = GIMarshallingTests.param_spec_out
    res.value_type.must_equal GObject::TYPE_STRING
    res.get_name.must_equal 'test-param'
  end

  it 'has a working function #param_spec_return' do
    skip unless get_introspection_data 'GIMarshallingTests', 'param_spec_return'
    res = GIMarshallingTests.param_spec_return
    res.value_type.must_equal GObject::TYPE_STRING
    res.get_name.must_equal 'test-param'
  end

  it 'has a working function #pointer_in_return' do
    ptr = FFI::MemoryPointer.new 1
    res = GIMarshallingTests.pointer_in_return ptr
    assert_equal ptr.address, res.address
  end

  it 'has a working function #pointer_struct_get_type' do
    res = GIMarshallingTests.pointer_struct_get_type
    gtype = GObject.type_from_name 'GIMarshallingTestsPointerStruct'
    assert_equal gtype, res
  end

  it 'has a working function #pointer_struct_returnv' do
    res = GIMarshallingTests.pointer_struct_returnv
    assert_instance_of GIMarshallingTests::PointerStruct, res
    assert_equal 42, res.long_
  end

  it 'has a working function #return_gvalue_flat_array' do
    result = GIMarshallingTests.return_gvalue_flat_array
    arr = result.to_a
    arr[0].get_value.must_equal 42
    arr[1].get_value.must_equal '42'
    arr[2].get_value.must_equal true
  end

  it 'has a working function #short_in_max' do
    GIMarshallingTests.short_in_max 0x7fff
    pass
  end

  it 'has a working function #short_in_min' do
    GIMarshallingTests.short_in_min(-0x8000)
    pass
  end

  it 'has a working function #short_inout_max_min' do
    res = GIMarshallingTests.short_inout_max_min 0x7fff
    assert_equal(-0x8000, res)
  end

  it 'has a working function #short_inout_min_max' do
    res = GIMarshallingTests.short_inout_min_max(-0x8000)
    assert_equal 0x7fff, res
  end

  it 'has a working function #short_out_max' do
    res = GIMarshallingTests.short_out_max
    assert_equal 0x7fff, res
  end

  it 'has a working function #short_out_min' do
    res = GIMarshallingTests.short_out_min
    assert_equal(-0x8000, res)
  end

  it 'has a working function #short_return_max' do
    res = GIMarshallingTests.short_return_max
    assert_equal 0x7fff, res
  end

  it 'has a working function #short_return_min' do
    res = GIMarshallingTests.short_return_min
    assert_equal(-0x8000, res)
  end

  it 'has a working function #simple_struct_returnv' do
    res = GIMarshallingTests.simple_struct_returnv
    assert_instance_of GIMarshallingTests::SimpleStruct, res
    assert_equal 6, res.long_
    assert_equal 7, res.int8
  end

  it 'has a working function #size_in' do
    GIMarshallingTests.size_in max_size_t
  end

  it 'has a working function #size_inout' do
    res = GIMarshallingTests.size_inout max_size_t
    assert_equal 0, res
  end

  it 'has a working function #size_out' do
    res = GIMarshallingTests.size_out
    assert_equal max_size_t, res
  end

  it 'has a working function #size_return' do
    res = GIMarshallingTests.size_return
    assert_equal max_size_t, res
  end

  it 'has a working function #ssize_in_max' do
    GIMarshallingTests.ssize_in_max max_ssize_t
    pass
  end

  it 'has a working function #ssize_in_min' do
    GIMarshallingTests.ssize_in_min min_ssize_t
    pass
  end

  it 'has a working function #ssize_inout_max_min' do
    res = GIMarshallingTests.ssize_inout_max_min max_ssize_t
    assert_equal min_ssize_t, res
  end

  it 'has a working function #ssize_inout_min_max' do
    res = GIMarshallingTests.ssize_inout_min_max min_ssize_t
    assert_equal max_ssize_t, res
  end

  it 'has a working function #ssize_out_max' do
    res = GIMarshallingTests.ssize_out_max
    assert_equal max_ssize_t, res
  end

  it 'has a working function #ssize_out_min' do
    res = GIMarshallingTests.ssize_out_min
    assert_equal min_ssize_t, res
  end

  it 'has a working function #ssize_return_max' do
    res = GIMarshallingTests.ssize_return_max
    assert_equal max_ssize_t, res
  end

  it 'has a working function #ssize_return_min' do
    res = GIMarshallingTests.ssize_return_min
    assert_equal min_ssize_t, res
  end

  it 'has a working function #test_interface_test_int8_in' do
    derived_klass.class_eval { include GIMarshallingTests::Interface }
    instance = make_derived_instance do |info|
      info.install_vfunc_implementation :test_int8_in, proc { |obj, in_| obj.int = in_ }
    end
    instance.int.must_equal 0
    GIMarshallingTests.test_interface_test_int8_in instance, 8
    instance.int.must_equal 8
  end

  it 'has a working function #time_t_in' do
    GIMarshallingTests.time_t_in 1_234_567_890
    pass
  end

  it 'has a working function #time_t_inout' do
    res = GIMarshallingTests.time_t_inout 1_234_567_890
    assert_equal 0, res
  end

  it 'has a working function #time_t_out' do
    res = GIMarshallingTests.time_t_out
    assert_equal 1_234_567_890, res
  end

  it 'has a working function #time_t_return' do
    res = GIMarshallingTests.time_t_return
    assert_equal 1_234_567_890, res
  end

  it 'has a working function #uint16_in' do
    GIMarshallingTests.uint16_in 0xffff
    pass
  end

  it 'has a working function #uint16_inout' do
    res = GIMarshallingTests.uint16_inout 0xffff
    assert_equal 0, res
  end

  it 'has a working function #uint16_out' do
    res = GIMarshallingTests.uint16_out
    assert_equal 0xffff, res
  end

  it 'has a working function #uint16_return' do
    res = GIMarshallingTests.uint16_return
    assert_equal 0xffff, res
  end

  it 'has a working function #uint32_in' do
    GIMarshallingTests.uint32_in 0xffffffff
  end

  it 'has a working function #uint32_inout' do
    res = GIMarshallingTests.uint32_inout 0xffffffff
    assert_equal 0, res
  end

  it 'has a working function #uint32_out' do
    res = GIMarshallingTests.uint32_out
    assert_equal 0xffffffff, res
  end

  it 'has a working function #uint32_return' do
    res = GIMarshallingTests.uint32_return
    assert_equal 0xffffffff, res
  end

  it 'has a working function #uint64_in' do
    GIMarshallingTests.uint64_in 0xffff_ffff_ffff_ffff
    pass
  end

  it 'has a working function #uint64_inout' do
    res = GIMarshallingTests.uint64_inout 0xffff_ffff_ffff_ffff
    assert_equal 0, res
  end

  it 'has a working function #uint64_out' do
    res = GIMarshallingTests.uint64_out
    assert_equal 0xffff_ffff_ffff_ffff, res
  end

  it 'has a working function #uint64_return' do
    res = GIMarshallingTests.uint64_return
    assert_equal 0xffff_ffff_ffff_ffff, res
  end

  it 'has a working function #uint8_in' do
    GIMarshallingTests.uint8_in 0xff
  end

  it 'has a working function #uint8_inout' do
    res = GIMarshallingTests.uint8_inout 0xff
    assert_equal 0, res
  end

  it 'has a working function #uint8_out' do
    res = GIMarshallingTests.uint8_out
    assert_equal 0xff, res
  end

  it 'has a working function #uint8_return' do
    res = GIMarshallingTests.uint8_return
    assert_equal 0xff, res
  end

  it 'has a working function #uint_in' do
    GIMarshallingTests.uint_in max_uint
    pass
  end

  it 'has a working function #uint_inout' do
    res = GIMarshallingTests.uint_inout max_uint
    assert_equal 0, res
  end

  it 'has a working function #uint_out' do
    res = GIMarshallingTests.uint_out
    assert_equal max_uint, res
  end

  it 'has a working function #uint_return' do
    res = GIMarshallingTests.uint_return
    assert_equal max_uint, res
  end

  it 'has a working function #ulong_in' do
    GIMarshallingTests.ulong_in max_ulong
  end

  it 'has a working function #ulong_inout' do
    res = GIMarshallingTests.ulong_inout max_ulong
    assert_equal 0, res
  end

  it 'has a working function #ulong_out' do
    res = GIMarshallingTests.ulong_out
    assert_equal max_ulong, res
  end

  it 'has a working function #ulong_return' do
    res = GIMarshallingTests.ulong_return
    assert_equal max_ulong, res
  end

  it 'has a working function #union_inout' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #union_out' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #union_returnv' do
    res = GIMarshallingTests.union_returnv
    assert_instance_of GIMarshallingTests::Union, res
    assert_equal 42, res.long_
  end

  it 'has a working function #ushort_in' do
    GIMarshallingTests.ushort_in max_ushort
    pass
  end

  it 'has a working function #ushort_inout' do
    res = GIMarshallingTests.ushort_inout max_ushort
    assert_equal 0, res
  end

  it 'has a working function #ushort_out' do
    res = GIMarshallingTests.ushort_out
    assert_equal max_ushort, res
  end

  it 'has a working function #ushort_return' do
    res = GIMarshallingTests.ushort_return
    assert_equal max_ushort, res
  end

  it 'has a working function #utf8_as_uint8array_in' do
    skip unless get_introspection_data 'GIMarshallingTests', 'utf8_as_uint8array_in'
    GIMarshallingTests.utf8_as_uint8array_in GIMarshallingTests::CONSTANT_UTF8.bytes.to_a
    pass
  end

  it 'has a working function #utf8_dangling_out' do
    res = GIMarshallingTests.utf8_dangling_out
    assert_nil res
  end

  it 'has a working function #utf8_full_in' do
    skip 'This function is defined in the header but not implemented'
  end

  it 'has a working function #utf8_full_inout' do
    res = GIMarshallingTests.utf8_full_inout 'const ♥ utf8'
    assert_equal '', res
  end

  it 'has a working function #utf8_full_out' do
    res = GIMarshallingTests.utf8_full_out
    assert_equal 'const ♥ utf8', res
  end

  it 'has a working function #utf8_full_return' do
    res = GIMarshallingTests.utf8_full_return
    assert_equal 'const ♥ utf8', res
  end

  it 'has a working function #utf8_none_in' do
    GIMarshallingTests.utf8_none_in 'const ♥ utf8'
    pass
  end

  it 'has a working function #utf8_none_inout' do
    res = GIMarshallingTests.utf8_none_inout 'const ♥ utf8'
    assert_equal '', res
  end

  it 'has a working function #utf8_none_out' do
    res = GIMarshallingTests.utf8_none_out
    assert_equal 'const ♥ utf8', res
  end

  it 'has a working function #utf8_none_return' do
    res = GIMarshallingTests.utf8_none_return
    assert_equal 'const ♥ utf8', res
  end
end
