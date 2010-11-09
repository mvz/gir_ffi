require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi/base'

class SubClass < GirFFI::Base
  # Boilerplate to make regular #new work again.
  def initialize
  end
  def self.new
    self._real_new
  end
  def this_is_my_name
    method_name
  end
end

class BaseTest < Test::Unit::TestCase
  context "A class derived from GirFFI::Base" do
    should "be able to use method_name to get the names of its methods" do
      assert_equal "this_is_my_name", SubClass.new.this_is_my_name
    end
  end
end
