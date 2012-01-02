require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GLib::HashTable do
  it "knows its key and value types" do
    hsh = GLib::HashTable.new :gint32, :utf8
    assert_equal :gint32, hsh.key_type
    assert_equal :utf8, hsh.value_type
  end

  describe "::from" do
    it "creates a GHashTable from a Ruby array" do
      hsh = GLib::HashTable.from [:utf8, :gint32],
        {"foo" => 23, "bar" => 32}
      assert_equal({"foo" => 23, "bar" => 32}, hsh.to_hash)
    end

    it "return its argument if given a GHashTable" do
      hsh = GLib::HashTable.from [:utf8, :gint32], {"foo" => 23, "bar" => 32}
      hsh2 = GLib::HashTable.from [:utf8, :gint32], hsh
      assert_equal hsh, hsh2
    end

    it "wraps its argument if given a pointer" do
      hsh = GLib::HashTable.from [:utf8, :gint32], {"foo" => 23, "bar" => 32}
      pointer = hsh.to_ptr
      assert_instance_of FFI::Pointer, pointer
      hsh2 = GLib::HashTable.from [:utf8, :gint32], pointer
      assert_instance_of GLib::HashTable, hsh2
      refute_equal hsh, hsh2
      assert_equal hsh.to_hash, hsh2.to_hash
    end
  end
end

