require 'gir_ffi_test_helper'

describe GirFFI::Builders::VFuncBuilder do
  let(:builder) { GirFFI::Builders::VFuncBuilder.new vfunc_info }

  describe "#mapping_method_definition" do
    describe "for a vfunc with only one argument" do
      let(:vfunc_info) {
        get_vfunc_introspection_data "GIMarshallingTests", "Object", "method_int8_in" }

      it "returns a valid mapping method including receiver" do
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _instance, in_)
          _v1 = GIMarshallingTests::Object.wrap(_instance)
          _v2 = in_
          _proc.call(_v1, _v2)
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a vfunc returning an enum" do
      let(:vfunc_info) {
        get_vfunc_introspection_data "GIMarshallingTests", "Object", "vfunc_return_enum" }

      it "returns a valid mapping method including receiver" do
        skip unless vfunc_info
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _instance)
          _v1 = GIMarshallingTests::Object.wrap(_instance)
          _v2 = _proc.call(_v1)
          _v3 = GIMarshallingTests::Enum.from(_v2)
          return _v3
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a vfunc with a callback argument" do
      let(:vfunc_info) {
        get_vfunc_introspection_data "GIMarshallingTests", "Object", "vfunc_with_callback" }

      it "returns a valid mapping method including receiver" do
        skip unless vfunc_info
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _instance, callback, callback_data)
          _v1 = GIMarshallingTests::Object.wrap(_instance)
          _v2 = GIMarshallingTests::CallbackIntInt.wrap(callback)
          _v3 = GirFFI::ArgHelper::OBJECT_STORE.fetch(callback_data)
          _proc.call(_v1, _v2, _v3)
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a vfunc with an out argument allocated by them, the caller" do
      let(:vfunc_info) {
        get_vfunc_introspection_data("GIMarshallingTests", "Object",
                                     "method_int8_arg_and_out_caller") }

      it "returns a valid mapping method including receiver" do
        skip unless vfunc_info
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _instance, arg, out)
          _v1 = GIMarshallingTests::Object.wrap(_instance)
          _v2 = arg
          _v3 = GirFFI::InOutPointer.new(:gint8, out)
          _v4 = _proc.call(_v1, _v2)
          _v3.set_value _v4
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a vfunc with an out argument allocated by us, the callee" do
      let(:vfunc_info) {
        get_vfunc_introspection_data("GIMarshallingTests", "Object",
                                     "method_int8_arg_and_out_callee") }

      it "returns a valid mapping method including receiver" do
        skip unless vfunc_info
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _instance, arg, out)
          _v1 = GIMarshallingTests::Object.wrap(_instance)
          _v2 = arg
          _v3 = GirFFI::InOutPointer.new(:gint8).tap { |ptr| out.put_pointer 0, ptr }
          _v4 = _proc.call(_v1, _v2)
          _v3.set_value _v4
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a vfunc with an error argument" do
      let(:vfunc_info) {
        get_vfunc_introspection_data("GIMarshallingTests", "Object",
                                     "vfunc_meth_with_err") }

      it "returns a valid mapping method including receiver" do
        skip unless vfunc_info
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _instance, x, _error)
          _v1 = GIMarshallingTests::Object.wrap(_instance)
          _v2 = x
          begin
          _v3 = _proc.call(_v1, _v2)
          rescue => _v4
          _error.put_pointer 0, GLib::Error.from_exception(_v4)
          end
          return _v3
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end
  end
end

