require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi/class_base'

class CkassBaseTest < Test::Unit::TestCase
  context "A class derived from GirFFI::Base" do
    setup do
      @klass = Class.new(GirFFI::ClassBase) do
	# Boilerplate to make regular #new work again.
	def initialize; end
	def self.new; self._real_new; end
      end
    end
    # TODO: See if we can test some part of Base again.
    should "pass" do
      assert true
    end
  end
end
