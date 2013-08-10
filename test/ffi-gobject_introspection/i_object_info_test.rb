require 'introspection_test_helper'

describe GObjectIntrospection::IObjectInfo do
  describe "#find_vfunc" do
    setup do
      gir = GObjectIntrospection::IRepository.default
      gir.require 'GObject', nil
      @info = gir.find_by_name 'GObject', 'Object'
    end

    it "finds a vfunc by name" do
      @info.find_vfunc("finalize").wont_be_nil
    end
  end
end
