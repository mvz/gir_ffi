require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GLib::PtrArray do
  it "knows its element type" do
    arr = GLib::PtrArray.new :utf8
    assert_equal :utf8, arr.element_type
  end
end
