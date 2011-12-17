require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

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

    it "returns an enumerator if no block is given" do
      en = @arr.each
      assert_equal 1, en.next
      assert_equal 2, en.next
      assert_equal 3, en.next
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
      assert_equal arr, arr2
    end

    it "wraps its argument if given a pointer" do
      arr = GLib::Array.new :gint32
      arr.append_vals [3, 2, 1]
      pointer = arr.to_ptr
      assert_instance_of FFI::Pointer, pointer
      arr2 = GLib::Array.from :gint32, pointer
      assert_instance_of GLib::Array, arr2
      refute_equal arr, arr2
      assert_equal arr.to_a, arr2.to_a
    end
  end
end

