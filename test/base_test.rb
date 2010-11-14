require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi/base'

class BaseTest < Test::Unit::TestCase
  context "A class derived from GirFFI::Base" do
    setup do
      @klass = Class.new(GirFFI::Base) do
	# Boilerplate to make regular #new work again.
	def initialize; end
	def self.new; self._real_new; end
      end
    end
  end
end
