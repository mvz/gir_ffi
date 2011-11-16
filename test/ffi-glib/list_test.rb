require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GLib::List do
  it "knows its element type" do
    arr = GLib::List.new :gint32
    assert_equal :gint32, arr.element_type
  end

  describe "#append" do
    it "appends integer values" do
      lst = GLib::List.new :gint32
      res = lst.append 1
      assert_equal 1, res[:data].address
    end

    it "appends string values" do
      lst = GLib::List.new :utf8
      res = lst.append "bla"
      assert_equal "bla", res[:data].read_string
    end

    it "appends multiple values into a single list" do
      lst = GLib::List.new :gint32

      lst = lst.append 1
      lst = lst.append 2

      assert_equal 1, lst[:data].address
      nxt = GLib::List.wrap(:gint32, lst[:next])
      assert_equal 2, nxt[:data].address
    end
  end

  it "can be created from an array" do
    lst = GLib::List.from_array :gint32, [3, 2, 1]
    assert_equal [3, 2, 1], lst.to_a
  end
end
