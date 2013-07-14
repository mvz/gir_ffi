require 'gir_ffi_test_helper'

describe GLib::Array do
  it "knows its element type" do
    arr = GLib::Array.new :gint32
    assert_equal :gint32, arr.element_type
  end

  describe "#append_vals" do
    before do
      @arr = GLib::Array.new :gint32
      @result = @arr.append_vals [1, 2, 3]
    end

    it "appends values" do
      assert_equal 3, @arr.len
    end

    it "returns self" do
      assert_equal @result, @arr
    end
  end

  describe "#each" do
    before do
      @arr = GLib::Array.new(:gint32).append_vals [1, 2, 3]
    end

    it "iterates over the values" do
      a = []
      @arr.each {|v| a << v }

      assert_equal [1, 2, 3], a
    end
  end

  describe "::wrap" do
    it "wraps a pointer, taking the element type as the first argument" do
      arr = GLib::Array.new :gint32
      arr.append_vals [1, 2, 3]
      arr2 = GLib::Array.wrap :gint32, arr.to_ptr
      assert_equal arr.to_a, arr2.to_a
    end

    it "raises an error if the element sizes don't match" do
      arr = GLib::Array.new :gint32
      arr.append_vals [1, 2, 3]
      assert_raises RuntimeError do
        GLib::Array.wrap :gint8, arr.to_ptr
      end
    end

    it "handles a struct as the element type" do
      vals = [1, 2, 3].map {|i| GObject::EnumValue.new.tap {|ev| ev.value = i} }
      arr = GLib::Array.new GObject::EnumValue
      arr.append_vals vals
      arr2 = GLib::Array.wrap GObject::EnumValue, arr.to_ptr
      arr2.to_a.must_equal arr.to_a
    end
  end

  it "includes Enumerable" do
    GLib::Array.must_include Enumerable
  end

  it "has a working #to_a method" do
    arr = GLib::Array.new :gint32
    arr.append_vals [1, 2, 3]
    assert_equal [1, 2, 3], arr.to_a
  end

  describe "::from" do
    it "creates a GArray from a Ruby array" do
      arr = GLib::Array.from :gint32, [3, 2, 1]
      assert_equal [3, 2, 1], arr.to_a
    end

    it "return its argument if given a GArray" do
      arr = GLib::Array.new :gint32
      arr.append_vals [3, 2, 1]
      arr2 = GLib::Array.from :foo, arr
      assert arr2.equal? arr
    end

    it "wraps its argument if given a pointer" do
      arr = GLib::Array.new :gint32
      arr.append_vals [3, 2, 1]
      pointer = arr.to_ptr
      assert_instance_of FFI::Pointer, pointer
      arr2 = GLib::Array.from :gint32, pointer
      assert_instance_of GLib::Array, arr2
      refute arr2.equal? arr
      arr2.to_a.must_equal arr.to_a
    end
  end

  describe "#==" do
    it "returns true when comparing to an array with the same elements" do
      arr = GLib::Array.from :gint32, [1, 2, 3]

      arr.must_be :==, [1, 2, 3]
    end

    it "returns false when comparing to an array with different elements" do
      arr = GLib::Array.from :gint32, [1, 2, 3]

      arr.wont_be :==, [1, 2]
    end

    it "returns true when comparing to a GArray with the same elements" do
      arr = GLib::Array.from :gint32, [1, 2, 3]
      other = GLib::Array.from :gint32, [1, 2, 3]

      arr.must_be :==, other
    end

    it "returns false when comparing to a GArray with different elements" do
      arr = GLib::Array.from :gint32, [1, 2, 3]
      other = GLib::Array.from :gint32, [1, 2]

      arr.wont_be :==, other
    end
  end
end

