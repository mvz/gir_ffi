require File.expand_path('../helper.rb', File.dirname(__FILE__))
require 'girffi/helper/arg'

class HelperArgTest < Test::Unit::TestCase
  context "The int_to_inoutptr method's return value" do
    setup do
      @result = GirFFI::Helper::Arg.int_to_inoutptr 24
    end

    should "be a FFI::MemoryPointer" do
      assert_equal "FFI::MemoryPointer", @result.class.to_s
    end

    should "hold a pointer to the correct input value" do
      assert_equal 24, @result.read_int
    end
  end

  context "The string_array_to_inoutptr method's return value" do
    setup do
      @result = GirFFI::Helper::Arg.string_array_to_inoutptr ["foo", "bar", "baz"]
    end

    should "be a FFI::MemoryPointer" do
      assert_equal "FFI::MemoryPointer", @result.class.to_s
    end

    should "hold a pointer to an array of pointers to strings" do
      ptr = @result.read_pointer
      ary = ptr.read_array_of_pointer(3)
      assert_equal ["foo", "bar", "baz"], ary.map {|p| p.read_string}
    end
  end

  context "The outptr_to_int method" do
    setup do
      @ptr = FFI::MemoryPointer.new(:int)
      @ptr.write_int 342
    end

    should "retrieve the correct integer value" do
      assert_equal 342, GirFFI::Helper::Arg.outptr_to_int(@ptr)
    end
  end

  context "The outptr_to_string_array method" do
    setup do
      p = FFI::MemoryPointer.new(:pointer, 2)
      p.write_array_of_pointer ["one", "two"].map {|a|
	FFI::MemoryPointer.from_string a }
      @ptr = FFI::MemoryPointer.new(:pointer)
      @ptr.write_pointer p
    end

    should "retrieve the correct string array" do
      assert_equal ["one", "two"],
	GirFFI::Helper::Arg.outptr_to_string_array(@ptr, 2)
    end
  end
end
