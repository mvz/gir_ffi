require 'introspection_test_helper'

describe GObjectIntrospection::IRepository do
  describe "an instance" do
    it "is not created by calling new()" do
      assert_raises NoMethodError do
        GObjectIntrospection::IRepository.new
      end
    end

    it "is created by calling default()" do
      gir = GObjectIntrospection::IRepository.default
      assert_kind_of GObjectIntrospection::IRepository, gir
    end

    it "is a singleton" do
      gir = GObjectIntrospection::IRepository.default
      gir2 = GObjectIntrospection::IRepository.default
      assert_equal gir, gir2
    end
  end

  describe "#require" do
    it "raises an error if the namespace doesn't exist" do
      assert_raises RuntimeError do
        GObjectIntrospection::IRepository.default.require 'VeryUnlikelyGObjectNamespaceName', nil
      end
    end

    it "allows version to be nil" do
      GObjectIntrospection::IRepository.default.require 'GObject', nil
      pass
    end

    it "allows version to be left out" do
      GObjectIntrospection::IRepository.default.require 'GObject'
      pass
    end
  end

  describe "enumerating the infos for GObject" do
    before do
      @gir = GObjectIntrospection::IRepository.default
      @gir.require 'GObject', "2.0"
    end

    it "yields more than one object" do
      assert_operator @gir.n_infos('GObject'), :>, 0
    end

    it "yields IBaseInfo objects" do
      assert_kind_of GObjectIntrospection::IBaseInfo, @gir.info('GObject', 0)
    end
  end
end
