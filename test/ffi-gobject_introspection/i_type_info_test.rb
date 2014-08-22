require 'introspection_test_helper'

describe GObjectIntrospection::ITypeInfo do
  describe "#name?" do
    let(:object_info) { get_introspection_data('GIMarshallingTests', 'Object') }
    let(:vfunc_info) { object_info.find_vfunc('vfunc_array_out_parameter') }
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
