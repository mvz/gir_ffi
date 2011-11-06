require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GLib::Array do
  it "knows its element type" do
    arr = GLib::Array.new :int32
    assert_equal :int32, arr.element_type
  end

  describe "#append_vals" do
    before do
      @arr = GLib::Array.new :int32
      @result = @arr.append_vals [1, 2, 3]
    end

    it "appends values" do
      assert_equal 3, @arr[:len]
    end

    it "returns self" do
      assert_equal @result, @arr
    end
  end

  describe "#each" do
    before do
      @arr = GLib::Array.new(:int32).append_vals [1, 2, 3]
    end

    it "iterates over the values" do
      a = []
      @arr.each {|v| a << v }

      assert_equal [1, 2, 3], a
    end

    it "returns an enumerator if no block is given" do
      assert_instance_of Enumerator, @arr.each
    end
  end

  it "includes Enumerable" do
    GLib::Array.must_include Enumerable
  end

  it "has a working #to_a method" do
    arr = GLib::Array.new :int32
    arr.append_vals [1, 2, 3]
    assert_equal [1, 2, 3], arr.to_a
  end
end

