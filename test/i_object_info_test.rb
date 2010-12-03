require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

module GirFFI
  class IObjectInfoTest < Test::Unit::TestCase
    context "An IObjectInfo object" do

      setup do
	gir = IRepository.default
	gir.require 'Everything', nil
	@info = gir.find_by_name 'Everything', 'TestObj'
      end

      should "find a vfunc by name" do
	assert_not_nil @info.find_vfunc("matrix")
      end
    end

  end
end

