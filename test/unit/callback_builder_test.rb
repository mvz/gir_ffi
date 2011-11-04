require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Callback do
  describe "#pretty_print" do
    it "returns a statement assigning the callback to a constant" do
      mock(info = Object.new).safe_name { "TheCallback" }
      stub(info).namespace { "Foo" }
      mock(GirFFI::Builder).ffi_function_return_type(info) { :ret_type }
      mock(GirFFI::Builder).ffi_function_argument_types(info) { [ :baz, :qux ] }

      builder = GirFFI::Builder::Type::Callback.new(info)

      assert_equal "TheCallback = Lib.callback :TheCallback, [:baz, :qux], :ret_type",
        builder.pretty_print
    end
  end
end


