require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GLib::HashTable do
  it "knows its key and value types" do
    hsh = GLib::HashTable.new :gint32, :utf8
    assert_equal :gint32, hsh.key_type
    assert_equal :utf8, hsh.value_type
  end
end

