require 'introspection_test_helper'

describe GObjectIntrospection::ITypeInfo do
  describe "#name?" do
    let(:vfunc_info) {
      get_vfunc_introspection_data('GIMarshallingTests', 'Object',
                                   'vfunc_array_out_parameter') }
    let(:arg_info) { vfunc_info.args[0] }
    let(:type_info) { arg_info.argument_type }

    it "raises an error" do
      skip unless vfunc_info
      proc {
        type_info.name
      }.must_raise RuntimeError
    end
  end
end
