require 'test_helper'

module GirFFI
  class IObjectInfoTest < MiniTest::Spec
    context "An IObjectInfo object" do

      setup do
	gir = GObjectIntrospection::IRepository.default
	gir.require 'GObject', nil
	@info = gir.find_by_name 'GObject', 'Object'
      end

      should "find a vfunc by name" do
	assert_not_nil @info.find_vfunc("finalize")
      end
    end

  end
end

