# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::Builders::CallbackArgumentBuilder do
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:builder) { GirFFI::Builders::CallbackArgumentBuilder.new(var_gen, arg_info) }

  describe "for an argument with direction :out" do
    describe "for :zero_terminated" do
      let(:vfunc_info) do
        get_vfunc_introspection_data("GIMarshallingTests", "Object",
                                     "vfunc_array_out_parameter")
      end
      let(:arg_info) { vfunc_info.args[0] }

      it "has the correct value for #pre_conversion" do
        _(builder.pre_conversion).must_equal ["_v1 = a"]
      end

      it "has the correct value for #post_conversion" do
        _(builder.post_conversion).must_equal ["_v1.put_pointer 0, GirFFI::ZeroTerminated.from(:gfloat, _v2)"]
      end
    end

    describe "when the argument is allocated by us, the callee" do
      let(:vfunc_info) do
        get_vfunc_introspection_data("GIMarshallingTests", "Object",
                                     "method_int8_arg_and_out_callee")
      end

      let(:arg_info) { vfunc_info.args[1] }

      it "has the correct value for #pre_conversion" do
        _(builder.pre_conversion).must_equal ["_v1 = FFI::MemoryPointer.new(:int8).tap { |ptr| out.put_pointer 0, ptr }"]
      end

      it "has the correct value for #post_conversion" do
        _(builder.post_conversion).must_equal ["_v1.put_int8 0, _v2"]
      end
    end
  end

  describe "for an argument with direction :error" do
    let(:arg_info) { GirFFI::ErrorArgumentInfo.new }

    it "sets up a rescueing block in #pre_conversion" do
      _(builder.pre_conversion).must_equal [
        "_v1 = _error",
        "begin"
      ]
    end

    it "converts any exceptions to GLib::Error in #post_conversion" do
      _(builder.post_conversion).must_equal [
        "rescue => _v1",
        "_v2.put_pointer 0, GLib::Error.from(_v1)",
        "end"
      ]
    end
  end

  describe "for an argument with direction :inout" do
    let(:callback_info) do
      get_introspection_data("Regress",
                             "TestCallbackArrayInOut")
    end
    let(:array_arg_info) { callback_info.args[0] }
    let(:array_arg_builder) do
      GirFFI::Builders::CallbackArgumentBuilder.new(var_gen, array_arg_info)
    end
    let(:length_arg_info) { callback_info.args[1] }
    let(:length_arg_builder) do
      GirFFI::Builders::CallbackArgumentBuilder.new(var_gen, length_arg_info)
    end

    before do
      length_arg_builder.array_arg = array_arg_builder
      array_arg_builder.length_arg = length_arg_builder
    end

    describe "for arrays with a length argument" do
      it "provides a call argument name" do
        _(array_arg_builder.call_argument_name).must_equal "_v1"
      end

      it "provides a capture variable name" do
        _(array_arg_builder.capture_variable_name).must_equal "_v1"
      end

      it "has the correct value for #pre_conversion" do
        _(array_arg_builder.pre_conversion)
          .must_equal ["_v1 = ints",
                       "_v2 = GirFFI::SizedArray.wrap(:gint32, _v3, _v1.get_pointer(0))"]
      end

      it "has the correct value for #post_conversion" do
        array_arg_builder.pre_conversion
        _(array_arg_builder.post_conversion)
          .must_equal ["_v1.put_pointer 0, GirFFI::SizedArray.from(:gint32, -1, _v4)"]
      end
    end

    describe "for an array length argument" do
      it "does not provide a call argument name" do
        _(length_arg_builder.call_argument_name).must_be_nil
      end

      it "does not provide a capture variable name" do
        _(length_arg_builder.capture_variable_name).must_be_nil
      end

      it "has the correct value for #pre_conversion" do
        _(length_arg_builder.pre_conversion)
          .must_equal ["_v1 = length",
                       "_v2 = _v1.get_int32(0)"]
      end

      it "has the correct value for #post_conversion" do
        length_arg_builder.pre_conversion
        _(length_arg_builder.post_conversion)
          .must_equal ["_v1.put_int32 0, _v3.length"]
      end
    end
  end
end
