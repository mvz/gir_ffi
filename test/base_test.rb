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

    should "be able to use method_name to get the names of its methods" do
      @klass.class_eval do
	def this_is_my_name
	  method_name
	end
      end
      assert_equal "this_is_my_name", @klass.new.this_is_my_name
    end

    context "its #_fake_missing method" do
      should "not be missing" do
	assert @klass.new.respond_to? :_fake_missing
      end

      should "call method_missing" do
	@klass.class_eval do
	  def method_missing method, *args
	    method
	  end
	end
	assert_equal :_fake_missing, @klass.new._fake_missing
      end

      should "pass on its arguments" do
	@klass.class_eval do
	  def method_missing method, *args
	    args.join(', ')
	  end
	end
	assert_equal "a, b", @klass.new._fake_missing("a", "b")
      end

      should "pass on a given block" do
	@klass.class_eval do
	  def method_missing method, *args
	    yield if block_given?
	  end
	end
	assert_equal :called, @klass.new._fake_missing { :called }
      end
    end

    should "be able to use alias_method to create a self-defining method" do
      @klass.class_eval do
	def method_missing method, *args
	  self.class.class_eval "
	    undef #{method}
	    def #{method}
	      :redefined
	    end
	  "
	  self.send method
	end
	alias_method :new_method, :_fake_missing
      end
      assert_equal :redefined, @klass.new.new_method
    end
  end
end
