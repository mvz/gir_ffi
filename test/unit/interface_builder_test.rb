require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Interface do
  describe "#pretty_print" do
    it "returns a module block, extending InterfaceBase" do
      mock(info = Object.new).safe_name { "Bar" }
      stub(info).namespace { "Foo" }

      builder = GirFFI::Builder::Type::Interface.new(info)

      assert_equal "module Bar\n  extend InterfaceBase\nend", builder.pretty_print
    end
  end
end



