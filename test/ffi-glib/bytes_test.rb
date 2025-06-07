# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GLib::Bytes do
  it "can succesfully be created with GLib::Bytes.new" do
    bytes = GLib::Bytes.new [1, 2, 3]

    _(bytes).must_be_instance_of GLib::Bytes
  end

  it "has a working #get_size method" do
    bytes = GLib::Bytes.new [1, 2, 3]

    _(bytes.get_size).must_equal 3
  end

  it "has #size as an alias for #get_size" do
    bytes = GLib::Bytes.new [1, 2, 3]

    _(bytes.size).must_equal 3
  end

  it "has a working #get_data method" do
    bytes = GLib::Bytes.new [1, 2, 3]

    _(bytes.get_data.to_a).must_equal [1, 2, 3]
  end

  it "has a working #each method" do
    a = []
    bytes = GLib::Bytes.new [1, 2, 3]
    bytes.each do |v|
      a.unshift v
    end

    _(a).must_equal [3, 2, 1]
  end

  it "has a working #to_a method" do
    bytes = GLib::Bytes.new [1, 2, 3]

    _(bytes.to_a).must_equal [1, 2, 3]
  end

  describe ".from" do
    it "creates a GLib::Bytes object form an array of small integers" do
      bytes = GLib::Bytes.from [1, 2, 3]

      _(bytes).must_be_instance_of GLib::Bytes
      _(bytes.to_a).must_equal [1, 2, 3]
    end

    it "returns its argument if given a GLib::Bytes object" do
      bytes = GLib::Bytes.new [1, 2, 3]
      result = GLib::Bytes.from bytes

      assert_same result, bytes
    end

    it "wraps its argument if given a pointer" do
      bytes = GLib::Bytes.new [1, 2, 3]
      ptr = bytes.to_ptr
      result = GLib::Bytes.from ptr

      _(result.to_a).must_equal [1, 2, 3]
      _(result.to_ptr).must_equal ptr
    end
  end
end
