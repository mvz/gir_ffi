require 'gir_ffi_test_helper'

describe GirFFI::Builder::Type::Union do
  before do
    @cbuilder = GirFFI::Builder::Type::Union.new get_introspection_data('GObject', 'TypeCValue')
  end

  it "returns false looking for a method that doesn't exist" do
    assert_equal false, @cbuilder.setup_instance_method('blub')
  end

  describe "#pretty_print" do
    it "returns a class block" do
      mock(info = Object.new).safe_name { "Bar" }
      stub(info).namespace { "Foo" }

      builder = GirFFI::Builder::Type::Union.new(info)

      assert_equal "class Bar\nend", builder.pretty_print
    end
  end
end

