require 'gir_ffi_test_helper'

describe GirFFI::Builder::Type::Enum do
  describe "#pretty_print" do
    it "returns a statement assigning the enum to a constant" do
      mock(info = Object.new).safe_name { "TheEnum" }
      stub(info).namespace { "Foo" }

      mock(val1 = Object.new).name { "value1" }
      mock(val1).value { 1 }
      mock(val2 = Object.new).name { "value2" }
      mock(val2).value { 2 }

      mock(info).values { [val1, val2] }

      builder = GirFFI::Builder::Type::Enum.new(info)

      assert_equal "TheEnum = Lib.enum :TheEnum, [:value1, 1, :value2, 2]",
        builder.pretty_print
    end
  end
end



