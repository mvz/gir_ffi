# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GLib::SList do
  it "knows its element type" do
    arr = GLib::SList.new :gint32

    assert_equal :gint32, arr.element_type
  end

  describe "#append" do
    it "updates the list object itself" do
      lst = GLib::SList.new :gint32
      res = lst.append 1

      _(res.to_ptr).must_equal lst.to_ptr
    end

    it "appends integer values" do
      lst = GLib::SList.new :gint32
      lst.append 1

      _(lst.data).must_equal 1
    end

    it "appends string values" do
      lst = GLib::SList.new :utf8
      lst.append "bla"

      _(lst.data).must_equal "bla"
    end

    it "appends multiple values into a single list" do
      lst = GLib::SList.new :gint32
      lst.append 1
      lst.append 2

      _(lst).must_be :==, [1, 2]
    end
  end

  describe "#prepend" do
    it "updates the list object itself" do
      lst = GLib::SList.new :gint32
      res = lst.prepend 1

      _(res.to_ptr).must_equal lst.to_ptr
    end

    it "prepends integer values" do
      lst = GLib::SList.new :gint32
      lst.prepend 1

      _(lst).must_be :==, [1]
    end

    it "prepends string values" do
      lst = GLib::SList.new :utf8
      lst.prepend "bla"

      _(lst).must_be :==, ["bla"]
    end

    it "prepends multiple values into a single list" do
      lst = GLib::SList.new :gint32

      lst.prepend 1
      lst.prepend 2

      _(lst).must_be :==, [2, 1]
    end
  end

  describe "::from" do
    it "creates a GSList from a Ruby array" do
      lst = GLib::SList.from :gint32, [3, 2, 1]

      assert_equal [3, 2, 1], lst.to_a
    end

    it "return its argument if given a GSList" do
      lst = GLib::SList.from :gint32, [3, 2, 1]
      lst2 = GLib::SList.from :gint32, lst

      assert_equal lst, lst2
    end

    it "creates a GSList from a Ruby range" do
      lst = GLib::SList.from :gint32, (1..3)

      assert_equal [1, 2, 3], lst.to_a
    end
  end

  describe "#==" do
    it "returns true when comparing to an array with the same elements" do
      list = GLib::SList.from :gint32, [1, 2, 3]

      _(list).must_be :==, [1, 2, 3]
    end

    it "returns false when comparing to an array with different elements" do
      list = GLib::SList.from :gint32, [1, 2, 3]

      _(list).wont_be :==, [1, 2]
    end

    it "returns true when comparing to a list with the same elements" do
      list = GLib::SList.from :gint32, [1, 2, 3]
      other = GLib::SList.from :gint32, [1, 2, 3]

      _(list).must_be :==, other
    end

    it "returns false when comparing to a list with different elements" do
      list = GLib::SList.from :gint32, [1, 2, 3]
      other = GLib::SList.from :gint32, [1, 2]

      _(list).wont_be :==, other
    end

    it "returns true when comparing an empty list with an empty array" do
      list = GLib::SList.from :gint32, []

      _(list).must_be :==, []
    end
  end
end
