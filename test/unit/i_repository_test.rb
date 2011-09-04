require File.expand_path('../test_helper.rb', File.dirname(__FILE__))

describe GirFFI::IRepository do
  describe "an instance" do
    should "not be created by calling new()" do
      assert_raises NoMethodError do
        GirFFI::IRepository.new
      end
    end

    should "be created by calling default()" do
      gir = GirFFI::IRepository.default
      assert_kind_of GirFFI::IRepository, gir
    end

    should "be a singleton" do
      gir = GirFFI::IRepository.default
      gir2 = GirFFI::IRepository.default
      assert_equal gir, gir2
    end
  end

  describe "#namespace" do
    should "raise an error if the namespace doesn't exist" do
      assert_raises RuntimeError do
        GirFFI::IRepository.default.require 'VeryUnlikelyGObjectNamespaceName', nil
      end
    end

    should "allow version to be nil" do
      assert_nothing_raised do
        GirFFI::IRepository.default.require 'GObject', nil
      end
    end

    should "allow version to be left out" do
      assert_nothing_raised do
        GirFFI::IRepository.default.require 'GObject'
      end
    end
  end

  describe "enumerating the infos for Gtk" do
    setup do
      @gir = GirFFI::IRepository.default
      @gir.require 'Gtk', "2.0"
    end

    should "yield more than one object" do
      assert_operator @gir.n_infos('Gtk'), :>, 0
    end

    should "yield IBaseInfo objects" do
      assert_kind_of GirFFI::IBaseInfo, @gir.info('Gtk', 0)
    end
  end
end
