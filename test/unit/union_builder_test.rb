require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Union do
  describe "#pretty_print" do
    it "returns a class block" do
      mock(info = Object.new).safe_name { "Bar" }
      stub(info).namespace { "Foo" }

      builder = GirFFI::Builder::Type::Union.new(info)

      assert_equal "class Bar\nend", builder.pretty_print
    end
  end
end



