# frozen_string_literal: true

require "base_test_helper"

describe GObjectIntrospection::Strv do
  it "wraps a pointer" do
    strv = GObjectIntrospection::Strv.new :some_pointer

    assert_equal :some_pointer, strv.to_ptr
  end

  describe "::wrap" do
    it "takes a pointer and returns a GObjectIntrospection::Strv wrapping it" do
      ptr = instance_double FFI::Pointer, null?: false
      strv = GObjectIntrospection::Strv.wrap ptr

      assert_instance_of GObjectIntrospection::Strv, strv
      assert_equal ptr, strv.to_ptr
    end

    it "returns nil when passed a null pointer" do
      strv = GObjectIntrospection::Strv.wrap FFI::Pointer::NULL

      _(strv).must_be_nil
    end
  end

  describe "#each" do
    it "yields each string element" do
      ary = %w[one two three]
      ptrs = ary.map { |a| FFI::MemoryPointer.from_string(a) }
      ptrs << nil
      block = FFI::MemoryPointer.new(:pointer, ptrs.length)
      block.write_array_of_pointer ptrs

      strv = GObjectIntrospection::Strv.new block
      arr = []
      strv.each do |str| # rubocop:disable Style/MapIntoArray
        arr << str
      end

      assert_equal %w[one two three], arr
    end

    it "yields zero times for a Strv wrapping an empty block of strings" do
      ptrs = [nil]
      block = FFI::MemoryPointer.new(:pointer, ptrs.length)
      block.write_array_of_pointer ptrs
      strv = GObjectIntrospection::Strv.new block

      strv.each do |_str|
        flunk
      end
    end

    it "yields zero times for a Strv wrapping a null pointer" do
      strv = GObjectIntrospection::Strv.new FFI::Pointer.new(0)

      strv.each do |_str|
        flunk
      end
    end
  end

  it "includes Enumerable" do
    _(GObjectIntrospection::Strv).must_include Enumerable
  end
end
