# frozen_string_literal: true

require 'gir_ffi_test_helper'

GirFFI.setup :Regress
GirFFI.setup :GIMarshallingTests

describe GirFFI::Builder do
  let(:gir) { GObjectIntrospection::IRepository.default }

  describe '.build_class' do
    it 'does not replace existing classes' do
      oldclass = GObject::Object
      GirFFI::Builder.build_class get_introspection_data('GObject', 'Object')
      _(GObject::Object).must_equal oldclass
    end
  end

  describe '.build_module' do
    it 'refuses to build existing modules defined elsewhere' do
      result = _(-> { GirFFI::Builder.build_module('Array') }).must_raise RuntimeError
      _(result.message).must_equal 'The module Array was already defined elsewhere'
    end

    describe 'building a module for the first time' do
      before do
        save_module :Regress
        GirFFI::Builder.build_module 'Regress'
      end

      it 'creates a Lib module ready to attach functions from the shared library' do
        gir = GObjectIntrospection::IRepository.default
        expected = [gir.shared_library('Regress')]
        assert_equal expected, Regress::Lib.ffi_libraries.map(&:name)
      end

      after do
        restore_module :Regress
      end
    end

    describe 'building a module that already exists' do
      it 'does not replace the existing module' do
        oldmodule = Regress
        GirFFI::Builder.build_module 'Regress'
        assert_equal oldmodule, Regress
      end

      it 'does not replace the existing Lib module' do
        oldmodule = Regress::Lib
        GirFFI::Builder.build_module 'Regress'
        assert_equal oldmodule, Regress::Lib
      end
    end

    it 'passes the version on to ModuleBuilder' do
      builder = double(generate: nil)
      expect(GirFFI::Builders::ModuleBuilder).to receive(:new).
        with('Foo', namespace: 'Foo', version: '1.0').
        and_return builder

      GirFFI::Builder.build_module 'Foo', '1.0'
    end
  end

  describe '.build_by_gtype' do
    it 'returns the class types known to the GIR' do
      result = GirFFI::Builder.build_by_gtype GObject::Object.gtype
      _(result).must_equal GObject::Object
    end

    it 'returns the class for user-defined types' do
      klass = Class.new GIMarshallingTests::OverridesObject
      Object.const_set "Derived#{Sequence.next}", klass
      gtype = GirFFI.define_type klass

      found_klass = GirFFI::Builder.build_by_gtype gtype
      _(found_klass).must_equal klass
    end

    it 'returns a valid class for boxed classes unknown to GIR' do
      object_class = GIMarshallingTests::PropertiesObject.object_class
      property = object_class.find_property 'some-boxed-glist'
      gtype = property.value_type

      _(gtype).wont_equal GObject::TYPE_NONE

      found_klass = GirFFI::Builder.build_by_gtype gtype
      _(found_klass.name).must_be_nil
      _(found_klass.superclass).must_equal GirFFI::BoxedBase
    end
  end

  describe '.attach_ffi_function' do
    let(:lib) { Module.new }

    it 'calls attach_function with the correct types for Regress.test_callback_destroy_notify' do
      function_info = get_introspection_data 'Regress', 'test_callback_destroy_notify'

      expect(lib).
        to receive(:attach_function).
        with('regress_test_callback_destroy_notify',
             [Regress::TestCallbackUserData, :pointer, GLib::DestroyNotify],
             :int32).
        and_return true

      GirFFI::Builder.attach_ffi_function(lib, function_info)
    end

    it 'calls attach_function with the correct types for Regress::TestObj#torture_signature_0' do
      info = get_method_introspection_data 'Regress', 'TestObj', 'torture_signature_0'

      expect(lib).
        to receive(:attach_function).
        with('regress_test_obj_torture_signature_0',
             [:pointer, :int32, :pointer, :pointer, :pointer, :pointer, :uint32],
             :void).
        and_return true

      GirFFI::Builder.attach_ffi_function(lib, info)
    end

    it 'calls attach_function with the correct types for Regress::TestObj#instance_method' do
      info = get_method_introspection_data 'Regress', 'TestObj', 'instance_method'
      expect(lib).to receive(:attach_function).
        with('regress_test_obj_instance_method', [:pointer], :int32).
        and_return true
      GirFFI::Builder.attach_ffi_function(lib, info)
    end

    it 'calls attach_function with the correct types for Regress.test_array_gint32_in' do
      info = get_introspection_data 'Regress', 'test_array_gint32_in'
      expect(lib).to receive(:attach_function).
        with('regress_test_array_gint32_in', [:int32, :pointer], :int32).
        and_return true
      GirFFI::Builder.attach_ffi_function(lib, info)
    end

    it 'calls attach_function with the correct types for Regress.test_enum_param' do
      info = get_introspection_data 'Regress', 'test_enum_param'
      expect(lib).to receive(:attach_function).
        with('regress_test_enum_param', [Regress::TestEnum], :pointer).
        and_return true
      GirFFI::Builder.attach_ffi_function(lib, info)
    end

    it 'does not attach the function if it is already defined' do
      info = get_introspection_data 'Regress', 'test_array_gint32_in'
      allow(lib).to receive(:method_defined?).and_return true
      expect(lib).not_to receive(:attach_function)
      GirFFI::Builder.attach_ffi_function(lib, info)
    end
  end

  #
  # NOTE: Legacy tests below.
  #

  describe 'looking at Regress.test_callback_destroy_notify' do
    before do
      save_module :GObject
      save_module :Regress
      GirFFI::Builder.build_module 'GObject'
      GirFFI::Builder.build_module 'Regress'
      @go = get_introspection_data 'Regress', 'test_callback_destroy_notify'
    end

    it 'defines ffi callback types :Callback and :ClosureNotify' do
      Regress.setup_method! 'test_callback_destroy_notify'
      tcud = Regress::Lib.find_type :TestCallbackUserData
      dn = GLib::Lib.find_type :DestroyNotify

      assert_equal FFI.find_type(:int32), tcud.result_type
      assert_equal FFI.find_type(:void), dn.result_type
      assert_equal [FFI.find_type(:pointer)], tcud.param_types
      assert_equal [FFI.find_type(:pointer)], dn.param_types
    end

    after do
      restore_module :Regress
      restore_module :GObject
    end
  end

  describe 'building Regress::TestBoxed' do
    before do
      GirFFI::Builder.build_class get_introspection_data('Regress', 'TestBoxed')
    end

    it 'sets up #wrap' do
      assert Regress::TestBoxed.respond_to? 'wrap'
    end

    it 'sets up #allocate' do
      assert Regress::TestBoxed.respond_to? 'allocate'
    end
  end

  describe 'built Regress module' do
    before do
      save_module :Regress
      GirFFI::Builder.build_module 'Regress'
    end

    it 'autocreates singleton methods' do
      refute_defines_singleton_method Regress, :test_uint
      Regress.test_uint 31
      assert_defines_singleton_method Regress, :test_uint
    end

    it 'autocreates the TestObj class on first access' do
      assert !Regress.const_defined?(:TestObj)
      _(Regress::TestObj).must_be_instance_of Class
      assert Regress.const_defined? :TestObj
    end

    it 'knows its own module builder' do
      _(Regress.gir_ffi_builder).must_be_instance_of GirFFI::Builders::ModuleBuilder
    end

    after do
      restore_module :Regress
    end
  end

  describe 'having built Regress::TestObj' do
    before do
      GirFFI::Builder.build_class get_introspection_data('Regress', 'TestObj')
    end

    it 'C functions for called instance methods get attached to Regress::Lib' do
      o = Regress::TestObj.new_from_file('foo')
      o.instance_method
      _(Regress::Lib).must_respond_to :regress_test_obj_instance_method
    end

    it 'the built class knows its own GIR info' do
      _(Regress::TestObj.gir_info.name).must_equal 'TestObj'
    end

    it 'the built class knows its own class builder' do
      _(Regress::TestObj.gir_ffi_builder).must_be_instance_of GirFFI::Builders::ObjectBuilder
    end
  end

  describe 'built Regress::TestSubObj' do
    it 'inherits #set_bare from its superclass' do
      o1 = Regress::TestSubObj.new
      o1.set_bare(nil)
      pass
    end

    it 'overrides #instance_method' do
      obj = Regress::TestObj.new_from_file('foo')
      subobj = Regress::TestSubObj.new

      _(obj.instance_method).must_equal(-1)
      _(subobj.instance_method).must_equal 0
    end
  end

  describe 'building Regress::TestSubObj' do
    before do
      save_module :Regress
      GirFFI::Builder.build_class get_introspection_data('Regress', 'TestSubObj')
    end

    it 'sets up the Regress namespace' do
      assert Regress.const_defined? :Lib
      assert Regress.respond_to? :gir_ffi_builder
      assert Regress.const_defined? :GIR_FFI_BUILDER
    end

    it 'creates the Regress::Lib module ready to attach functions from the shared library' do
      expected = [gir.shared_library('Regress')]
      assert_equal expected, Regress::Lib.ffi_libraries.map(&:name)
    end

    it 'builds parent classes also' do
      assert Regress.const_defined? :TestObj
      assert Object.const_defined? :GObject
      assert GObject.const_defined? :Object
    end

    it 'sets up the inheritance chain' do
      # Introduced in version 1.59.1
      expected = if Regress::TestSubObj.find_property :boolean
                   [Regress::TestSubObj,
                    Regress::TestInterface,
                    Regress::TestObj,
                    GObject::Object]
                 else
                   [Regress::TestSubObj,
                    Regress::TestObj,
                    GObject::Object]
                 end
      _(Regress::TestSubObj.registered_ancestors).must_equal expected
    end

    it 'creates a Regress::TestSubObj#to_ptr method' do
      assert Regress::TestSubObj.public_method_defined? :to_ptr
    end

    after do
      restore_module :Regress
    end
  end
end
