require 'gir_ffi_test_helper'

describe GLib::List do
  it "knows its element type" do
    arr = GLib::List.new :gint32
    assert_equal :gint32, arr.element_type
  end

  describe "#append" do
    it "appends integer values" do
      lst = GLib::List.new :gint32
      res = lst.append 1
      assert_equal 1, res.data
    end

    it "appends string values" do
      lst = GLib::List.new :utf8
      res = lst.append "bla"
      assert_equal "bla", res.data
    end

    it "appends multiple values into a single list" do
      lst = GLib::List.new :gint32

      lst = lst.append 1
      lst = lst.append 2

      assert_equal 1, lst.data
      nxt = lst.next
      assert_equal 2, nxt.data
    end
  end

  describe "::from" do
    it "creates a GList from a Ruby array" do
      lst = GLib::List.from :gint32, [3, 2, 1]
      assert_equal [3, 2, 1], lst.to_a
    end

    it "return its argument if given a GList" do
      lst = GLib::List.from :gint32, [3, 2, 1]
      lst2 = GLib::List.from :gint32, lst
      assert_equal lst, lst2
    end

    it "wraps its argument if given a pointer" do
      lst = GLib::List.from :gint32, [3, 2, 1]
      pointer = lst.to_ptr
      assert_instance_of FFI::Pointer, pointer
      lst2 = GLib::List.from :gint32, pointer
      assert_instance_of GLib::List, lst2
      refute_equal lst, lst2
      assert_equal lst.to_a, lst2.to_a
    end
  end
end
