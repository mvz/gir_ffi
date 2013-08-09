require 'introspection_test_helper'

describe GObjectIntrospection::IRepository do
  describe "an instance" do
    should "not be created by calling new()" do
      assert_raises NoMethodError do
        GObjectIntrospection::IRepository.new
      end
    end

    should "be created by calling default()" do
      gir = GObjectIntrospection::IRepository.default
      assert_kind_of GObjectIntrospection::IRepository, gir
    end

    should "be a singleton" do
      gir = GObjectIntrospection::IRepository.default
      gir2 = GObjectIntrospection::IRepository.default
      assert_equal gir, gir2
    end
  end

  # FIXME: Does not test #namespace
  describe "#namespace" do
    should "raise an error if the namespace doesn't exist" do
      assert_raises RuntimeError do
        GObjectIntrospection::IRepository.default.require 'VeryUnlikelyGObjectNamespaceName', nil
      end
    end

    should "allow version to be nil" do
      GObjectIntrospection::IRepository.default.require 'GObject', nil
      pass
    end

    should "allow version to be left out" do
      GObjectIntrospection::IRepository.default.require 'GObject'
      pass
    end
  end

  describe "enumerating the infos for GObject" do
    setup do
      @gir = GObjectIntrospection::IRepository.default
      @gir.require 'GObject', "2.0"
    end

    should "yield more than one object" do
      assert_operator @gir.n_infos('GObject'), :>, 0
    end

    should "yield IBaseInfo objects" do
      assert_kind_of GObjectIntrospection::IBaseInfo, @gir.info('GObject', 0)
    end
  end
end
