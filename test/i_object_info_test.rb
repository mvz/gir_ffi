require File.expand_path('test_helper.rb', File.dirname(__FILE__))

module GirFFI
  class IObjectInfoTest < MiniTest::Spec
    context "An IObjectInfo object" do

      setup do
	gir = IRepository.default
	gir.require 'Regress', nil
	@info = gir.find_by_name 'Regress', 'TestObj'
      end

      should "find a vfunc by name" do
	assert_not_nil @info.find_vfunc("matrix")
      end
    end

  end
end

