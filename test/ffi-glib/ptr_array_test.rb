require 'gir_ffi_test_helper'

describe GLib::PtrArray do
  it "knows its element type" do
    arr = GLib::PtrArray.new :utf8
    assert_equal :utf8, arr.element_type
  end

  describe "::add" do
    it "correctly takes the type into account" do
      arr = GLib::PtrArray.new :utf8
      str = "test"
      GLib::PtrArray.add arr, str

      assert_equal str, arr.pdata.read_pointer.read_string
    end
  end

  describe "#each" do
    it "works normally" do
      arr = GLib::PtrArray.new :utf8

      GLib::PtrArray.add arr, "test1"
      GLib::PtrArray.add arr, "test2"
      GLib::PtrArray.add arr, "test3"

      a = []
      arr.each {|v| a << v}

      assert_equal ["test1", "test2", "test3"], a
    end

    it "works when exiting the loop prematurely" do
      arr = GLib::PtrArray.new :utf8

      GLib::PtrArray.add arr, "test1"
      GLib::PtrArray.add arr, "test2"
      GLib::PtrArray.add arr, "test3"

      a = []
      arr.each do |v|
        a << v
        break if v == "test2"
      end

      assert_equal ["test1", "test2"], a
    end
  end

  it "includes Enumerable" do
    GLib::PtrArray.must_include Enumerable
  end

  it "has a working #to_a method" do
    arr = GLib::PtrArray.new :utf8

    GLib::PtrArray.add arr, "test1"
    GLib::PtrArray.add arr, "test2"
    GLib::PtrArray.add arr, "test3"

    assert_equal ["test1", "test2", "test3"], arr.to_a
  end

  it "has #add as an instance method too" do
    arr = GLib::PtrArray.new :utf8
    arr.add "test1"
    assert_equal ["test1"], arr.to_a
  end
end
