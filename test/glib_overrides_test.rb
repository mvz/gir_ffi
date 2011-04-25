require File.expand_path('test_helper.rb', File.dirname(__FILE__))

describe "With the GLib overrides" do
  describe "a HashTable provided by the system" do
    before do
      GirFFI.setup :Regress
      @hash = Regress.test_ghash_container_return
    end

    it "has a working #each method" do
      a = {}
      @hash.each {|k, v| a[k] = v}
      a.must_be :==, {"foo" => "bar", "baz" => "bat",
        "qux" => "quux"}
    end

    it "includes Enumerable" do
      GLib::HashTable.must_include Enumerable 
    end

    it "has a working #to_hash method" do
      @hash.to_hash.must_be :==, {"foo" => "bar", "baz" => "bat",
        "qux" => "quux"}
    end
  end

  describe "HashTable" do
    it "can be created (for now) with Glib.hash_table_new" do
      h = GLib.hash_table_new
      h.to_hash.must_be :==, {}
    end

    it "allows key-value pairs to be inserted" do
      h = GLib.hash_table_new
      h.insert "foo", "bar"
      h.to_hash.must_be :==, {"foo" => "bar"}
    end
  end

  describe "ByteArray" do
    it "can be created (for now) with Glib.byte_array_new" do
      ba = GLib.byte_array_new
      assert_instance_of GLib::ByteArray, ba
    end

    it "allows strings to be appended to it" do
      ba = GLib.byte_array_new
      GLib::byte_array_append ba, "abdc"
      pass
    end

    it "has a working #to_s method" do
      ba = GLib.byte_array_new
      ba = GLib::byte_array_append ba, "abdc"
      assert_equal "abdc", ba.to_string
    end
  end
end


