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

  describe "::from_array" do
    it "creates a GList from a Ruby array" do
      lst = GLib::List.from_array :gint32, [3, 2, 1]
      assert_equal [3, 2, 1], lst.to_a
    end

    it "return its argument if given a GList" do
      lst = GLib::List.from_array :gint32, [3, 2, 1]
      lst2 = GLib::List.from_array :gint32, lst
      assert_equal lst, lst2
    end
  end
end
