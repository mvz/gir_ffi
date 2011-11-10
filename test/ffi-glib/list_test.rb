require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GLib::List do
  it "knows its element type" do
    arr = GLib::List.new :int32
    assert_equal :int32, arr.element_type
  end
end
