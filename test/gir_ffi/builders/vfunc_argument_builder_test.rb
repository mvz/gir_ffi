# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::Builders::VFuncArgumentBuilder do
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:builder) { GirFFI::Builders::VFuncArgumentBuilder.new(var_gen, arg_info) }

  describe "for a plain in argument" do
    let(:vfunc_info) do
      get_vfunc_introspection_data "GIMarshallingTests", "Object", "method_int8_in"
    end
    let(:arg_info) { vfunc_info.args[0] }

    it "has the correct value for #pre_conversion" do
      _(builder.pre_conversion).must_equal ["_v1 = in_"]
    end

    it "has the correct value for #post_conversion" do
      _(builder.post_conversion).must_equal []
    end
  end

  describe "for a transfer-none in argument" do
    let(:vfunc_info) do
      get_vfunc_introspection_data "GIMarshallingTests", "Object", "vfunc_in_object_transfer_none"
    end
    let(:arg_info) { vfunc_info.args[0] }

    it "has the correct value for #pre_conversion" do
      _(builder.pre_conversion).must_equal ["_v1 = GObject::Object.wrap(object)", "_v1.ref"]
    end

    it "has the correct value for #post_conversion" do
      _(builder.post_conversion).must_equal []
    end
  end

  describe "for a transfer-none outgoing object argument" do
    let(:vfunc_info) do
      get_vfunc_introspection_data "GIMarshallingTests", "Object", "vfunc_out_object_transfer_none"
    end
    let(:arg_info) { vfunc_info.args[0] }

    it "has the correct value for #pre_conversion" do
      _(builder.pre_conversion).must_equal ["_v1 = object"]
    end

    it "has the correct value for #post_conversion" do
      _(builder.post_conversion).must_equal ["_v1.put_pointer 0, GObject::Object.from(_v2)"]
    end
  end

  describe "for a full-transfer outgoing object argument" do
    let(:vfunc_info) do
      get_vfunc_introspection_data "GIMarshallingTests", "Object", "vfunc_out_object_transfer_full"
    end
    let(:arg_info) { vfunc_info.args[0] }

    it "has the correct value for #pre_conversion" do
      _(builder.pre_conversion).must_equal ["_v1 = object"]
    end

    it "has the correct value for #post_conversion" do
      builder.pre_conversion
      _(builder.post_conversion).must_equal ["_v2.ref", "_v1.put_pointer 0, GObject::Object.from(_v2)"]
    end
  end

  describe "for a full-transfer outgoing non-object argument" do
    let(:vfunc_info) do
      get_vfunc_introspection_data("GIMarshallingTests", "Object",
                                   "method_int8_arg_and_out_callee")
    end
    let(:arg_info) { vfunc_info.args[1] }

    it "has the correct value for #pre_conversion" do
      _(builder.pre_conversion).
        must_equal ["_v1 = FFI::MemoryPointer.new(:int8).tap { |ptr| out.put_pointer 0, ptr }"]
    end

    it "has the correct value for #post_conversion" do
      _(builder.post_conversion).must_equal ["_v1.put_int8 0, _v2"]
    end
  end

  describe "for a receiver argument" do
    let(:object_info) { get_introspection_data("GIMarshallingTests", "Object") }
    let(:type_info) { GirFFI::ReceiverTypeInfo.new(object_info) }
    let(:arg_info) { GirFFI::ReceiverArgumentInfo.new(type_info) }

    it "has the correct value for #pre_conversion" do
      _(builder.pre_conversion).
        must_equal ["_v1 = GIMarshallingTests::Object.wrap(_instance)"]
    end

    it "has the correct value for #post_conversion" do
      _(builder.post_conversion).must_equal []
    end
  end
end
