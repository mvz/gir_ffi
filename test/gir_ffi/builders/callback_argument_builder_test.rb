require 'gir_ffi_test_helper'

describe GirFFI::Builders::CallbackArgumentBuilder do
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:builder) { GirFFI::Builders::CallbackArgumentBuilder.new(var_gen, arg_info) }

  describe "for an argument with direction :out" do
    describe "for :zero_terminated" do
      let(:arg_info) {
        get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                     'vfunc_array_out_parameter').args[0] }

      it "has the correct value for #pre_conversion" do
        builder.pre_conversion.must_equal [ "_v1 = GirFFI::InOutPointer.new([:pointer, :zero_terminated], a)" ]
      end

      it "has the correct value for #post_conversion" do
        builder.post_conversion.must_equal [ "_v1.set_value GirFFI::ZeroTerminated.from(:gfloat, _v2)" ]
      end
    end
  end
end
