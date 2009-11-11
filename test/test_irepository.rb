require File.expand_path('test_helper.rb', File.dirname(__FILE__))

module GIRepository
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
	gir2 = IRepository.default
	assert_equal gir, gir2
      end
    end
  end
end
