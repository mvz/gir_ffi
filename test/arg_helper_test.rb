require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'girffi/arg_helper'

class HelperArgTest < Test::Unit::TestCase
  context "The int_to_inoutptr method's return value" do
    setup do
      @result = GirFFI::ArgHelper.int_to_inoutptr 24
    end

    should "be a FFI::MemoryPointer" do
      assert_equal "FFI::MemoryPointer", @result.class.to_s
    end

    should "hold a pointer to the correct input value" do
      assert_equal 24, @result.read_int
    end
  end

  context "The string_array_to_inoutptr method" do
    context "when called with an array of strings" do
      setup do
	@result = GirFFI::ArgHelper.string_array_to_inoutptr ["foo", "bar", "baz"]
      end

      should "return a FFI::MemoryPointer" do
	assert_equal "FFI::MemoryPointer", @result.class.to_s
      end

      should "return a pointer to an array of pointers to strings" do
	ptr = @result.read_pointer
	ary = ptr.read_array_of_pointer(3)
	assert_equal ["foo", "bar", "baz"], ary.map {|p| p.read_string}
      end
    end
    context "when called with nil" do
      should "return nil" do
	assert_nil GirFFI::ArgHelper.string_array_to_inoutptr nil
      end
    end
  end

  context "The outptr_to_int method" do
    setup do
      @ptr = FFI::MemoryPointer.new(:int)
      @ptr.write_int 342
    end

    should "retrieve the correct integer value" do
      assert_equal 342, GirFFI::ArgHelper.outptr_to_int(@ptr)
    end
  end

  context "The outptr_to_string_array method" do
    context "when called with a pointer to a string array" do
      setup do
	p = FFI::MemoryPointer.new(:pointer, 2)
	p.write_array_of_pointer ["one", "two"].map {|a|
	  FFI::MemoryPointer.from_string a }
	@ptr = FFI::MemoryPointer.new(:pointer)
	@ptr.write_pointer p
      end

      should "return the string array" do
	assert_equal ["one", "two"],
	  GirFFI::ArgHelper.outptr_to_string_array(@ptr, 2)
      end
    end

    context "when called with nil" do
      should "return nil" do
	assert_nil GirFFI::ArgHelper.outptr_to_string_array(nil, 0)
      end
    end
  end

  context "The object_to_inptr method" do
    context "when called with an object implementing to_ptr" do
      should "return the result of to_ptr" do
	obj = Object.new
	def obj.to_ptr; :test_value; end
	assert_equal :test_value, GirFFI::ArgHelper.object_to_inptr(obj)
      end
    end

    context "when called with nil" do
      should "return nil" do
	assert_equal nil, GirFFI::ArgHelper.object_to_inptr(nil)
      end
    end
  end
end
