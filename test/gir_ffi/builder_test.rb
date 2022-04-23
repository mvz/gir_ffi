# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :Regress
GirFFI.setup :GIMarshallingTests

describe GirFFI::Builder do
  let(:gir) { GObjectIntrospection::IRepository.default }

  describe ".build_class" do
    it "does not replace existing classes" do
      oldclass = GObject::Object
      GirFFI::Builder.build_class get_introspection_data("GObject", "Object")
      _(GObject::Object).must_equal oldclass
    end
  end

  describe ".build_module" do
    it "refuses to build existing modules defined elsewhere" do
      result = _(-> { GirFFI::Builder.build_module("Array") }).must_raise RuntimeError
      _(result.message).must_equal "The module Array was already defined elsewhere"
    end

    it "creates a Lib module ready to attach functions from the shared library" do
      # Regress has already been build by GirFFI.setup, which will have done
      # something like:
      #
      #     GirFFI::Builder.build_module "Regress"
      #
      gir = GObjectIntrospection::IRepository.default
      expected = [gir.shared_library("Regress")]
      assert_equal expected, Regress::Lib.ffi_libraries.map(&:name)
    end

    it "does not replace an existing module" do
      oldmodule = Regress
      GirFFI::Builder.build_module "Regress"
      assert_equal oldmodule, Regress
    end

    it "does not replace the an existing module's Lib module" do
      oldmodule = Regress::Lib
      GirFFI::Builder.build_module "Regress"
      assert_equal oldmodule, Regress::Lib
    end

    it "passes the version on to ModuleBuilder" do
      builder = double(generate: nil)
      expect(GirFFI::Builders::ModuleBuilder).to receive(:new)
        .with("Foo", namespace: "Foo", version: "1.0")
        .and_return builder

      GirFFI::Builder.build_module "Foo", "1.0"
    end
  end

  describe ".build_by_gtype" do
    it "returns the class types known to the GIR" do
      result = GirFFI::Builder.build_by_gtype GObject::Object.gtype
      _(result).must_equal GObject::Object
    end

    it "returns the class for user-defined types" do
      klass = Class.new GIMarshallingTests::OverridesObject
      Object.const_set "Derived#{Sequence.next}", klass
      gtype = GirFFI.define_type klass

      found_klass = GirFFI::Builder.build_by_gtype gtype
      _(found_klass).must_equal klass
    end

    it "returns the class for user-defined types not derived from GObject" do
      klass = Class.new Regress::TestFundamentalObject
      Object.const_set "Derived#{Sequence.next}", klass
      gtype = GirFFI.define_type klass

      found_klass = GirFFI::Builder.build_by_gtype gtype
      _(found_klass).must_equal klass
    end

    it "returns a valid class for boxed classes unknown to GIR" do
      class_struct = GIMarshallingTests::PropertiesObject.class_struct
      property = class_struct.find_property "some-boxed-glist"
      gtype = property.value_type

      _(gtype).wont_equal GObject::TYPE_NONE

      found_klass = GirFFI::Builder.build_by_gtype gtype
      _(found_klass.name).must_be_nil
      _(found_klass.superclass).must_equal GirFFI::BoxedBase
    end

    it "refuse to build classes for base types" do
      _(-> { GirFFI::Builder.build_by_gtype GObject::TYPE_INT })
        .must_raise RuntimeError, "Unable to handle type gint"
    end
  end

  describe ".attach_ffi_function" do
    let(:lib) { Module.new }

    it "attaches regress_test_callback_destroy_notify with the correct types" do
      function_info = get_introspection_data "Regress", "test_callback_destroy_notify"

      expect(lib)
        .to receive(:attach_function)
        .with("regress_test_callback_destroy_notify",
              [Regress::TestCallbackUserData, :pointer, GLib::DestroyNotify],
              :int32)
        .and_return true

      GirFFI::Builder.attach_ffi_function(lib, function_info)
    end

    it "attaches regress_test_obj_torture_signature_0 with the correct types" do
      info = get_method_introspection_data "Regress", "TestObj", "torture_signature_0"

      expect(lib)
        .to receive(:attach_function)
        .with("regress_test_obj_torture_signature_0",
              [:pointer, :int32, :pointer, :pointer, :pointer, :pointer, :uint32],
              :void)
        .and_return true

      GirFFI::Builder.attach_ffi_function(lib, info)
    end

    it "attaches regress_test_obj_instance_method with the correct types" do
      info = get_method_introspection_data "Regress", "TestObj", "instance_method"
      expect(lib).to receive(:attach_function)
        .with("regress_test_obj_instance_method", [:pointer], :int32)
        .and_return true
      GirFFI::Builder.attach_ffi_function(lib, info)
    end

    it "calls attach_function with the correct types for Regress.test_array_gint32_in" do
      info = get_introspection_data "Regress", "test_array_gint32_in"
      expect(lib).to receive(:attach_function)
        .with("regress_test_array_gint32_in", [:int32, :pointer], :int32)
        .and_return true
      GirFFI::Builder.attach_ffi_function(lib, info)
    end

    it "calls attach_function with the correct types for Regress.test_enum_param" do
      info = get_introspection_data "Regress", "test_enum_param"
      expect(lib).to receive(:attach_function)
        .with("regress_test_enum_param", [Regress::TestEnum], :pointer)
        .and_return true
      GirFFI::Builder.attach_ffi_function(lib, info)
    end

    it "does not attach the function if it is already defined" do
      info = get_introspection_data "Regress", "test_array_gint32_in"
      allow(lib).to receive(:method_defined?).and_return true
      expect(lib).not_to receive(:attach_function)
      GirFFI::Builder.attach_ffi_function(lib, info)
    end
  end
end
