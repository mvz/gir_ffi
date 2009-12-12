require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'girffi/irepository'

module GirFFI
  class IRepositoryTest < Test::Unit::TestCase
    context "An IRepository object" do
      should "not be created by calling new()" do
	assert_raise NoMethodError do
	  IRepository.new
	end
      end

      should "be created by calling default()" do
	gir = IRepository.default
	assert_kind_of IRepository, gir
      end

      should "be a singleton" do
	gir = IRepository.default
	gir2 = IRepository.default
	assert_equal gir, gir2
      end
    end

    context "The namespace method" do
      should "raise an error if the namespace doesn't exist" do
	assert_raise RuntimeError do
	  IRepository.default.require 'VeryUnlikelyGObjectNamespaceName', nil
	end
      end

      should "allow version to be nil" do
	assert_nothing_raised do
	  IRepository.default.require 'Gtk', nil
	end
      end
    end

    context "Enumerating the infos" do
      setup do
	@gir = IRepository.default
	@gir.require 'Gtk', nil
      end

      should "yield more than one object" do
	assert_operator @gir.n_infos('Gtk'), :>, 0
      end

      should "yield IBaseInfo objects" do
	assert_kind_of IBaseInfo, @gir.info('Gtk', 0)
      end
    end
  end
end
