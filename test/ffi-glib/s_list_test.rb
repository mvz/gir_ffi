require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GLib::SList do
  it "knows its element type" do
    arr = GLib::SList.new :gint32
    assert_equal :gint32, arr.element_type
  end

  describe "#prepend" do
    it "prepends integer values" do
      lst = GLib::SList.new :gint32
      res = lst.prepend 1
      assert_equal 1, res[:data].address
    end

    it "prepends string values" do
      lst = GLib::SList.new :utf8
      res = lst.prepend "bla"
      assert_equal "bla", res[:data].read_string
    end

    it "prepends multiple values into a single list" do
      lst = GLib::SList.new :gint32

      res = lst.prepend 1
      res2 = res.prepend 2

      assert_equal 2, res2[:data].address
      assert_equal 1, res[:data].address
      assert_equal res.to_ptr, res2[:next]
    end
  end

  it "can be created from an array" do
    lst = GLib::SList.from_array :gint32, [3, 2, 1]
    assert_equal [3, 2, 1], lst.to_a
  end
end
