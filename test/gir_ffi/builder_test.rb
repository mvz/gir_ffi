require 'gir_ffi_test_helper'

GirFFI.setup :Regress

describe GirFFI::Builder do
  let(:gir) { GObjectIntrospection::IRepository.default }

  describe '.build_class' do
    it "does not replace existing classes" do
      oldclass = GObject::Object
      GirFFI::Builder.build_class get_introspection_data('GObject', 'Object')
      GObject::Object.must_equal oldclass
    end
  end

  describe '.attach_ffi_function' do
    let(:lib) { Module.new }
    it "calls attach_function with the correct types for Regress.test_callback_destroy_notify" do
      function_info = get_introspection_data 'Regress', 'test_callback_destroy_notify'

      mock(lib).
        attach_function("regress_test_callback_destroy_notify",
                        [ Regress::TestCallbackUserData, :pointer, GLib::DestroyNotify ],
                        :int32) { true }

      GirFFI::Builder.attach_ffi_function(lib, function_info)
    end

    it "calls attach_function with the correct types for Regress::TestObj#torture_signature_0" do
      info = get_method_introspection_data 'Regress', 'TestObj', 'torture_signature_0'

      mock(lib).
        attach_function("regress_test_obj_torture_signature_0",
                        [:pointer, :int32, :pointer, :pointer, :pointer, :pointer, :uint32],
                        :void) { true }

      GirFFI::Builder.attach_ffi_function(lib, info)
    end

    it "calls attach_function with the correct types for Regress::TestObj#instance_method" do
      info = get_method_introspection_data 'Regress', 'TestObj', 'instance_method'
      mock(lib).attach_function("regress_test_obj_instance_method",
                                [:pointer], :int32) { true }
      GirFFI::Builder.attach_ffi_function(lib, info)
    end

    it "calls attach_function with the correct types for Regress.test_array_gint32_in" do
      info = get_introspection_data 'Regress', 'test_array_gint32_in'
      mock(lib).attach_function("regress_test_array_gint32_in",
                                [:int32, :pointer], :int32) { true }
      GirFFI::Builder.attach_ffi_function(lib, info)
    end
  end

  describe "looking at Regress.test_callback_destroy_notify" do
    before do
      save_module :GObject
      save_module :Regress
      GirFFI::Builder.build_module 'GObject'
      GirFFI::Builder.build_module 'Regress'
      @go = get_introspection_data 'Regress', 'test_callback_destroy_notify'
    end

    it "defines ffi callback types :Callback and :ClosureNotify" do
      Regress.setup_method 'test_callback_destroy_notify'
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

  describe "building Regress::TestBoxed" do
    before do
      GirFFI::Builder.build_class get_introspection_data('Regress', 'TestBoxed')
    end

    it "sets up #wrap" do
      assert Regress::TestBoxed.respond_to? "wrap"
    end

    it "sets up #allocate" do
      assert Regress::TestBoxed.respond_to? "allocate"
    end
  end

  describe "built Regress module" do
    before do
      save_module :Regress
      GirFFI::Builder.build_module 'Regress'
    end

    it "autocreates singleton methods" do
      refute_defines_singleton_method Regress, :test_uint
      Regress.test_uint 31
      assert_defines_singleton_method Regress, :test_uint
    end

    it "autocreates the TestObj class on first access" do
      assert !Regress.const_defined?(:TestObj)
      Regress::TestObj.must_be_instance_of Class
      assert Regress.const_defined? :TestObj
    end

    it "knows its own module builder" do
      assert GirFFI::Builders::ModuleBuilder === Regress.gir_ffi_builder
    end

    after do
      restore_module :Regress
    end
  end

  describe "having built Regress::TestObj" do
    before do
      GirFFI::Builder.build_class get_introspection_data('Regress', 'TestObj')
    end

    it "C functions for called instance methods get attached to Regress::Lib" do
      o = Regress::TestObj.new_from_file("foo")
      o.instance_method
      Regress::Lib.must_respond_to :regress_test_obj_instance_method
    end

    it "the built class knows its own GIR info" do
      Regress::TestObj.gir_info.name.must_equal 'TestObj'
    end

    it "the built class knows its own class builder" do
      Regress::TestObj.gir_ffi_builder.must_be_instance_of GirFFI::Builders::ObjectBuilder
    end
  end

  describe "built Regress::TestSubObj" do
    it "inherits #set_bare from its superclass" do
      o1 = Regress::TestSubObj.new
      o1.set_bare(nil)
      pass
    end

    it "overrides #instance_method" do
      obj = Regress::TestObj.new_from_file("foo")
      subobj = Regress::TestSubObj.new

      obj.instance_method.must_equal(-1)
      subobj.instance_method.must_equal 0
    end
  end

  describe "building Regress::TestSubObj" do
    before do
      save_module :Regress
      GirFFI::Builder.build_class get_introspection_data('Regress', 'TestSubObj')
    end

    it "builds Regress namespace" do
      assert Regress.const_defined? :Lib
      assert Regress.respond_to? :method_missing
    end

    it "creates the Regress::Lib module ready to attach functions from the shared library" do
      expected = [gir.shared_library('Regress')]
      assert_equal expected, Regress::Lib.ffi_libraries.map(&:name)
    end

    it "builds parent classes also" do
      assert Regress.const_defined? :TestObj
      assert Object.const_defined? :GObject
      assert GObject.const_defined? :Object
    end

    it "sets up the inheritance chain" do
      ancestors = Regress::TestSubObj.ancestors
      assert_equal [
        Regress::TestSubObj,
        Regress::TestObj,
        GObject::Object
      ], ancestors[0..2]
    end

    it "creates a Regress::TestSubObj#to_ptr method" do
      assert Regress::TestSubObj.public_method_defined? :to_ptr
    end

    after do
      restore_module :Regress
    end
  end

  describe "building Regress" do
    before do
      save_module :Regress
      GirFFI::Builder.build_module 'Regress'
    end

    it "creates a Lib module ready to attach functions from the shared library" do
      gir = GObjectIntrospection::IRepository.default
      expected = [gir.shared_library('Regress')]
      assert_equal expected, Regress::Lib.ffi_libraries.map(&:name)
    end

    it "does not replace existing module" do
      oldmodule = Regress
      GirFFI::Builder.build_module 'Regress'
      assert_equal oldmodule, Regress
    end

    it "does not replace existing Lib module" do
      oldmodule = Regress::Lib
      GirFFI::Builder.build_module 'Regress'
      assert_equal oldmodule, Regress::Lib
    end

    after do
      restore_module :Regress
    end
  end
end
