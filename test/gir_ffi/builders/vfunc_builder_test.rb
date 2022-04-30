# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::Builders::VFuncBuilder do
  let(:builder) { GirFFI::Builders::VFuncBuilder.new vfunc_info }

  describe "#mapping_method_definition" do
    let(:result) { builder.mapping_method_definition }

    describe "for a vfunc with only one argument" do
      let(:vfunc_info) do
        get_vfunc_introspection_data "GIMarshallingTests", "Object", "method_int8_in"
      end

      it "returns a valid mapping method including receiver" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance, in_)
            _v1 = GIMarshallingTests::Object.wrap(_instance)
            _v2 = in_
            _proc.call(_v1, _v2)
          end
        CODE

        _(result).must_equal expected
      end
    end

    describe "for a vfunc returning an integer" do
      let(:vfunc_info) do
        get_vfunc_introspection_data "Regress", "TestObj", "matrix"
      end

      it "returns a valid mapping method including receiver" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance, somestr)
            _v1 = Regress::TestObj.wrap(_instance)
            _v2 = somestr.to_utf8
            _v3 = _proc.call(_v1, _v2)
            return _v3
          end
        CODE

        _(result).must_equal expected
      end
    end

    describe "for a vfunc returning an enum" do
      let(:vfunc_info) do
        get_vfunc_introspection_data "GIMarshallingTests", "Object", "vfunc_return_enum"
      end

      it "returns a valid mapping method including receiver" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance)
            _v1 = GIMarshallingTests::Object.wrap(_instance)
            _v2 = _proc.call(_v1)
            _v3 = GIMarshallingTests::Enum.to_int(_v2)
            return _v3
          end
        CODE

        _(result).must_equal expected
      end
    end

    describe "for a vfunc with a callback argument" do
      let(:vfunc_info) do
        get_vfunc_introspection_data "GIMarshallingTests", "Object", "vfunc_with_callback"
      end

      it "returns a valid mapping method including receiver" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance, callback, callback_data)
            _v1 = GIMarshallingTests::Object.wrap(_instance)
            _v2 = GIMarshallingTests::CallbackIntInt.wrap(callback)
            _v3 = GirFFI::ArgHelper::OBJECT_STORE.fetch(callback_data)
            _proc.call(_v1, _v2, _v3)
          end
        CODE

        _(result).must_equal expected
      end
    end

    describe "for a vfunc with an out argument allocated by them, the caller" do
      let(:vfunc_info) do
        get_vfunc_introspection_data("GIMarshallingTests", "Object",
                                     "method_int8_arg_and_out_caller")
      end

      it "returns a valid mapping method including receiver" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance, arg, out)
            _v1 = GIMarshallingTests::Object.wrap(_instance)
            _v2 = arg
            _v3 = out
            _v4 = _proc.call(_v1, _v2)
            _v3.put_int8 0, _v4
          end
        CODE

        _(result).must_equal expected
      end
    end

    describe "for a vfunc with an out argument allocated by the callee" do
      let(:vfunc_info) do
        get_vfunc_introspection_data("GIMarshallingTests", "Object",
                                     "method_int8_arg_and_out_callee")
      end

      it "returns a valid mapping method including receiver" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance, arg, out)
            _v1 = GIMarshallingTests::Object.wrap(_instance)
            _v2 = arg
            _v3 = FFI::MemoryPointer.new(:int8).tap { |ptr| out.put_pointer 0, ptr }
            _v4 = _proc.call(_v1, _v2)
            _v3.put_int8 0, _v4
          end
        CODE

        _(result).must_equal expected
      end
    end

    describe "for a vfunc with a GObject::Value out argument allocated by the caller" do
      let(:vfunc_info) do
        get_vfunc_introspection_data("GIMarshallingTests", "Object",
                                     "vfunc_caller_allocated_out_parameter")
      end

      it "returns a valid mapping method including receiver" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance, a)
            _v1 = GIMarshallingTests::Object.wrap(_instance)
            _v2 = a
            _v3 = _proc.call(_v1)
            GObject::Value.copy_value_to_pointer(GObject::Value.from(_v3), _v2)
          end
        CODE

        _(result).must_equal expected
      end
    end

    describe "for a vfunc with an error argument" do
      let(:vfunc_info) do
        get_vfunc_introspection_data("GIMarshallingTests", "Object",
                                     "vfunc_meth_with_err")
      end

      it "returns a valid mapping method including receiver" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance, x, _error)
            _v1 = GIMarshallingTests::Object.wrap(_instance)
            _v2 = x
            _v3 = _error
            begin
            _v4 = _proc.call(_v1, _v2)
            rescue => _v5
            _v3.put_pointer 0, GLib::Error.from(_v5)
            end
            return _v4
          end
        CODE

        _(result).must_equal expected
      end
    end

    describe "for a vfunc with a full-transfer return value" do
      let(:vfunc_info) do
        get_vfunc_introspection_data "GIMarshallingTests", "Object",
                                     "vfunc_return_object_transfer_full"
      end

      it "returns a valid mapping method" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance)
            _v1 = GIMarshallingTests::Object.wrap(_instance)
            _v2 = _proc.call(_v1)
            _v2.ref
            _v3 = GObject::Object.from(_v2).to_ptr
            return _v3
          end
        CODE

        _(result).must_equal expected
      end
    end

    describe "for a vfunc with a transfer-none in argument" do
      let(:vfunc_info) do
        get_vfunc_introspection_data "GIMarshallingTests", "Object",
                                     "vfunc_in_object_transfer_none"
      end

      it "returns a valid mapping method" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance, object)
            _v1 = GIMarshallingTests::Object.wrap(_instance)
            _v2 = GObject::Object.wrap(object)
            _v2&.ref
            _proc.call(_v1, _v2)
          end
        CODE

        _(result).must_equal expected
      end
    end

    describe "for a vfunc with a full-transfer outgoing argument" do
      let(:vfunc_info) do
        get_vfunc_introspection_data "GIMarshallingTests", "Object",
                                     "vfunc_out_object_transfer_full"
      end

      it "returns a valid mapping method" do
        expected = <<~CODE
          def self.call_with_argument_mapping(_proc, _instance, object)
            _v1 = GIMarshallingTests::Object.wrap(_instance)
            _v2 = object
            _v3 = _proc.call(_v1)
            _v3.ref
            _v2.put_pointer 0, GObject::Object.from(_v3)
          end
        CODE

        _(result).must_equal expected
      end
    end
  end

  describe "#argument_ffi_types" do
    let(:result) { builder.argument_ffi_types }

    describe "for a vfunc with only one argument" do
      let(:vfunc_info) do
        get_vfunc_introspection_data "GIMarshallingTests", "Object", "method_int8_in"
      end

      it "returns the correct FFI types including :pointer for the receiver" do
        _(result).must_equal [:pointer, :int8]
      end
    end
  end

  describe "#return_ffi_type" do
    let(:result) { builder.return_ffi_type }

    describe "for a vfunc returning an object" do
      let(:vfunc_info) do
        get_vfunc_introspection_data "GIMarshallingTests", "Object",
                                     "vfunc_return_object_transfer_full"
      end

      it "returns :pointer" do
        _(result).must_equal :pointer
      end
    end

    describe "for a vfunc returning an integer" do
      let(:vfunc_info) do
        get_vfunc_introspection_data "Regress", "TestObj", "matrix"
      end

      it "returns :int32" do
        _(result).must_equal :int32
      end
    end
  end
end
