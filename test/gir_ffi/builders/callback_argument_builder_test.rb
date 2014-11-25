require 'gir_ffi_test_helper'

describe GirFFI::Builders::CallbackArgumentBuilder do
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:builder) { GirFFI::Builders::CallbackArgumentBuilder.new(var_gen, arg_info) }

  describe "for an argument with direction :out" do
    describe "for :zero_terminated" do
      let(:vfunc_info) {
        get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                     'vfunc_array_out_parameter')
      }
      let(:arg_info) { vfunc_info.args[0] }

      before { skip unless vfunc_info }

      it "has the correct value for #pre_conversion" do
        builder.pre_conversion.must_equal ["_v1 = GirFFI::InOutPointer.new([:pointer, :zero_terminated], a)"]
      end

      it "has the correct value for #post_conversion" do
        builder.post_conversion.must_equal ["_v1.set_value GirFFI::ZeroTerminated.from(:gfloat, _v2)"]
      end
    end
  end

  describe "for an argument with direction :error" do
    let(:arg_info) { GirFFI::ErrorArgumentInfo.new }

    it "sets up a rescueing block in #pre_conversion" do
      builder.pre_conversion.must_equal [
        "_v1 = GirFFI::InOutPointer.new([:pointer, :error], _error)",
        "begin"
      ]
    end

    it "converts any exceptions to GLib::Error in #post_conversion" do
      builder.post_conversion.must_equal [
        "rescue => _v1",
        "_v2.set_value GLib::Error.from(_v1)",
        "end"
      ]
    end
  end

  describe "for an argument with direction :inout" do
    let(:callback_info) {
      get_introspection_data("Regress",
                             "TestCallbackArrayInOut")
    }
    let(:array_arg_info) { callback_info.args[0] }
    let(:array_arg_builder) {
      GirFFI::Builders::CallbackArgumentBuilder.new(var_gen, array_arg_info)
    }
    let(:length_arg_info) { callback_info.args[1] }
    let(:length_arg_builder) {
      GirFFI::Builders::CallbackArgumentBuilder.new(var_gen, length_arg_info)
    }
    before do
      length_arg_builder.array_arg = array_arg_builder
      array_arg_builder.length_arg = length_arg_builder
    end

    describe "for arrays with a length argument" do
      it "provides a call argument name" do
        array_arg_builder.call_argument_name.must_equal "_v1"
      end

      it "provides a capture variable name" do
        array_arg_builder.capture_variable_name.must_equal "_v1"
      end

      it "has the correct value for #pre_conversion" do
        array_arg_builder.pre_conversion.
          must_equal ["_v1 = GirFFI::InOutPointer.new([:pointer, :c], ints)",
                      "_v2 = GirFFI::SizedArray.wrap(:gint32, _v3, _v1.to_value)"]
      end

      it "has the correct value for #post_conversion" do
        array_arg_builder.pre_conversion
        array_arg_builder.post_conversion.
          must_equal ["_v1.set_value GirFFI::SizedArray.from(:gint32, -1, _v4)"]
      end
    end

    describe "for an array length argument" do
      it "does not provide a call argument name" do
        length_arg_builder.call_argument_name.must_be_nil
      end

      it "does not provide a capture variable name" do
        length_arg_builder.capture_variable_name.must_be_nil
      end

      it "has the correct value for #pre_conversion" do
        length_arg_builder.pre_conversion.
          must_equal ["_v1 = GirFFI::InOutPointer.new(:gint32, length)",
                      "_v2 = _v1.to_value"]
      end

      it "has the correct value for #post_conversion" do
        length_arg_builder.pre_conversion
        length_arg_builder.post_conversion.
          must_equal ["_v1.set_value _v3.length"]
      end
    end
  end
end
