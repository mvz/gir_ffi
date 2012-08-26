require 'test_helper'

require 'gir_ffi-base/glib/strv'
require 'gir_ffi/type_map'
require 'gir_ffi/arg_helper'

describe GLib::Strv do
  it "wraps a pointer" do
    strv = GLib::Strv.new :some_pointer
    assert_equal :some_pointer, strv.to_ptr
  end

  describe "::wrap" do
    it "takes a pointer and returns a GLib::Strv wrapping it" do
      strv = GLib::Strv.wrap :some_pointer
      assert_instance_of GLib::Strv, strv
      assert_equal :some_pointer, strv.to_ptr
    end
  end

  describe "#each" do
    it "yields each string element" do
      ptr = GirFFI::InPointer.from_array :utf8, ["one", "two", "three"]
      strv = GLib::Strv.new ptr
      arr = []
      strv.each do |str|
        arr << str
      end
      assert_equal ["one", "two", "three"], arr
    end

    it "yields zero times for a Strv wrapping a null pointer" do
      strv = GLib::Strv.new FFI::Pointer.new(0)
      strv.each do |str|
        flunk
      end
    end
  end

  it "includes Enumerable" do
    GLib::Strv.must_include Enumerable
  end
end
