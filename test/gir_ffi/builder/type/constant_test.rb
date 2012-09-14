require 'gir_ffi_test_helper'

describe GirFFI::Builder::Type::Constant do
  describe "#pretty_print" do
    it "returns the correct assignment statement" do
      mock(info = Object.new).value { "bar" }
      mock(info).safe_name { "FOO_CONSTANT" }
      stub(info).namespace { "Foo" }

      builder = GirFFI::Builder::Type::Constant.new(info)

      assert_equal "FOO_CONSTANT = \"bar\"", builder.pretty_print
    end
  end
end

