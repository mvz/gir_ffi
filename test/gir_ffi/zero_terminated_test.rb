require 'gir_ffi_test_helper'

describe GirFFI::ZeroTerminated do
  describe ".from" do
    let(:result) { GirFFI::ZeroTerminated.from :int32, [1, 2, 3] }

    it "converts the passed array into a zero-terminated c array" do
      ptr = result.to_ptr
      ptr.read_array_of_int32(4).must_equal [1, 2, 3, 0]
    end

    it "returns a GirFFI::ZeroTerminated object" do
      result.must_be_instance_of GirFFI::ZeroTerminated
    end
  end

  describe ".wrap" do
    it "wraps the given type and pointer" do
      ptr = GirFFI::InPointer.from_array :int32, [1, 2, 3, 0]
      zt = GirFFI::ZeroTerminated.wrap :foo, ptr
      zt.element_type.must_equal :foo
      zt.to_ptr.must_equal ptr
    end
  end

  describe "#each" do
    it "yields each element" do
      zt = GirFFI::ZeroTerminated.from :int32, [1, 2, 3]
      arr = []
      zt.each do |int|
        arr << int
      end
      arr.must_equal [1, 2, 3]
    end

    it "yields zero times for a ZeroTerminated wrapping a null pointer" do
      zt = GirFFI::ZeroTerminated.wrap :int32, FFI::Pointer.new(0)
      zt.each do |str|
        flunk
      end
    end

    it "works for :int8" do
      zt = GirFFI::ZeroTerminated.from :int8, [1, 2, 3]
      arr = []
      zt.each do |int|
        arr << int
      end
      arr.must_equal [1, 2, 3]
    end

  end

  it "includes Enumerable" do
    GirFFI::ZeroTerminated.must_include Enumerable
  end
end

