require 'base_test_helper'
require 'ffi-glib/sized_array'

describe GLib::SizedArray do
  describe "::wrap" do
    it "takes a type, size and pointer and returns a GLib::SizedArray wrapping them" do
      mock(ptr = Object.new).null? { false }
      sarr = GLib::SizedArray.wrap :gint32, 3, ptr
      assert_instance_of GLib::SizedArray, sarr
      assert_equal ptr, sarr.to_ptr
      assert_equal 3, sarr.size
      assert_equal :gint32, sarr.element_type
    end

    it "returns nil if the wrapped pointer is null" do
      mock(ptr = Object.new).null? { true }
      sarr = GLib::SizedArray.wrap :gint32, 3, ptr
      sarr.must_be_nil
    end
  end

  describe "#each" do
    it "yields each element" do
      ary = ["one", "two", "three"]
      ptrs = ary.map {|a| FFI::MemoryPointer.from_string(a)}
      ptrs << nil
      block = FFI::MemoryPointer.new(:pointer, ptrs.length)
      block.write_array_of_pointer ptrs

      sarr = GLib::SizedArray.new :utf8, 3, block
      arr = []
      sarr.each do |str|
        arr << str
      end
      assert_equal ["one", "two", "three"], arr
    end
  end

  it "includes Enumerable" do
    GLib::SizedArray.must_include Enumerable
  end
end

