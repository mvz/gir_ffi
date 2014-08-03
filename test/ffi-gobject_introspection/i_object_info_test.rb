require 'introspection_test_helper'

describe GObjectIntrospection::IObjectInfo do
  let(:object_info) { get_introspection_data('GObject', 'Object') }

  describe "#find_vfunc" do
    it "finds a vfunc by name" do
      object_info.find_vfunc("finalize").wont_be_nil
    end
  end

  describe "#type_name" do
    it "returns the correct name" do
      object_info.type_name.must_equal 'GObject'
    end
  end
end
