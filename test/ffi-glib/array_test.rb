# frozen_string_literal: true

require "gir_ffi_test_helper"

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
      @arr.each { |v| a << v } # rubocop:disable Style/MapIntoArray

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

    it "warns the element sizes don't match" do
      arr = GLib::Array.new :gint32
      arr.append_vals [1, 2, 3]

      _(proc { GLib::Array.wrap :gint8, arr.to_ptr }).must_output nil, /sizes do not match/
    end

    it "handles a struct as the element type" do
      vals = [1, 2, 3].map { |i| GObject::EnumValue.new.tap { |ev| ev.value = i } }
      arr = GLib::Array.new GObject::EnumValue
      arr.append_vals vals
      arr2 = GLib::Array.wrap GObject::EnumValue, arr.to_ptr

      _(arr2.to_a).must_equal arr.to_a
    end
  end

  it "includes Enumerable" do
    _(GLib::Array).must_include Enumerable
  end

  it "has a working #to_a method" do
    arr = GLib::Array.new :gint32
    arr.append_vals [1, 2, 3]

    assert_equal [1, 2, 3], arr.to_a
  end

  describe ".from" do
    it "creates a GArray from an array of :gint32" do
      arr = GLib::Array.from :gint32, [3, 2, 1]

      _(arr).must_be_instance_of GLib::Array
      _(arr.to_a).must_equal [3, 2, 1]
    end

    it "creates a GArray from an array of :gboolean" do
      arr = GLib::Array.from :gboolean, [true, false, true]

      _(arr).must_be_instance_of GLib::Array
      _(arr.to_a).must_equal [true, false, true]
    end

    it "creates a GArray from an array of :utf8 values" do
      arr = GLib::Array.from :utf8, %w[hello there]

      _(arr).must_be_instance_of GLib::Array
      _(arr.to_a).must_equal %w[hello there]
    end

    it "creates a GArray from an array of struct values" do
      values = [1, 2, 3].map do |val|
        GObject::EnumValue.new.tap { _1.value = val }
      end
      arr = GLib::Array.from GObject::EnumValue, values

      _(arr).must_be_instance_of GLib::Array
      _(arr.to_a.map(&:value)).must_equal [1, 2, 3]
    end

    it "return its argument if given a GArray" do
      arr = GLib::Array.new :gint32
      arr.append_vals [3, 2, 1]
      arr2 = GLib::Array.from :gint32, arr

      assert_same arr2, arr
    end

    it "wraps its argument if given a pointer" do
      arr = GLib::Array.new :gint32
      arr.append_vals [3, 2, 1]
      pointer = arr.to_ptr

      assert_instance_of FFI::Pointer, pointer
      arr2 = GLib::Array.from :gint32, pointer

      assert_instance_of GLib::Array, arr2
      refute_same arr2, arr
      _(arr2.to_a).must_equal arr.to_a
    end
  end

  describe "#==" do
    it "returns true when comparing to an array with the same elements" do
      arr = GLib::Array.from :gint32, [1, 2, 3]

      _(arr).must_be :==, [1, 2, 3]
    end

    it "returns false when comparing to an array with different elements" do
      arr = GLib::Array.from :gint32, [1, 2, 3]

      _(arr).wont_be :==, [1, 2]
    end

    it "returns true when comparing to a GArray with the same elements" do
      arr = GLib::Array.from :gint32, [1, 2, 3]
      other = GLib::Array.from :gint32, [1, 2, 3]

      _(arr).must_be :==, other
    end

    it "returns false when comparing to a GArray with different elements" do
      arr = GLib::Array.from :gint32, [1, 2, 3]
      other = GLib::Array.from :gint32, [1, 2]

      _(arr).wont_be :==, other
    end
  end

  describe "#index" do
    it "returns the proper element for an array of :gint32" do
      arr = GLib::Array.from :gint32, [1, 2, 3]

      _(arr.index(2)).must_equal 3
    end

    it "returns the proper element for an array of :utf8" do
      arr = GLib::Array.from :utf8, %w[a b c]

      _(arr.index(1)).must_equal "b"
    end

    it "returns the proper element for an array of :gboolean" do
      arr = GLib::Array.from :gboolean, [true, false, true]

      _(arr.index(1)).must_equal false
    end

    it "returns the proper element for an array of struct" do
      vals = [1, 2, 3].map { |i| GObject::EnumValue.new.tap { |ev| ev.value = i } }
      arr = GLib::Array.from GObject::EnumValue, vals

      _(arr.index(1).value).must_equal 2
    end

    it "raises an error if the index is out of bounds" do
      arr = GLib::Array.from :gint32, [1, 2, 3]

      _(proc { arr.index(16) }).must_raise IndexError
      _(proc { arr.index(-1) }).must_raise IndexError
    end
  end

  describe "#reset_typespec" do
    describe "when it needs to guess the type" do
      it "guesses :uint8 for size 1" do
        arr = GLib::Array.from :int8, [1, 2, 3]
        arr.reset_typespec

        _(arr.element_type).must_equal :uint8
      end

      it "guesses :uint16 for size 2" do
        arr = GLib::Array.from :int16, [1, 2, 3]
        arr.reset_typespec

        _(arr.element_type).must_equal :uint16
      end

      it "guesses :uint32 for size 4" do
        arr = GLib::Array.from :int32, [1, 2, 3]
        arr.reset_typespec

        _(arr.element_type).must_equal :uint32
      end

      it "guesses :uint64 for size 8" do
        arr = GLib::Array.from :int64, [1, 2, 3]
        arr.reset_typespec

        _(arr.element_type).must_equal :uint64
      end
    end
  end
end
