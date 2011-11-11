require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

require 'ffi-glib'

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
    it "allows key-value pairs to be inserted" do
      h = GLib::HashTable.new :utf8, :utf8
      h.insert "foo", "bar"
      h.to_hash.must_be :==, {"foo" => "bar"}
    end
  end
end


