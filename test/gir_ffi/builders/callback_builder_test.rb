require 'gir_ffi_test_helper'

describe GirFFI::Builders::CallbackBuilder do
  let(:builder) { GirFFI::Builders::CallbackBuilder.new callback_info }
  let(:callback_info) { get_introspection_data "Regress", "TestCallbackFull" }

  describe "#mapping_method_definition" do
    it "return a valid mapping method for Regress::TestCallbackFull" do
      expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _v1, _v2, _v3)
          _v4 = _v3.to_utf8
          _v5 = _proc.call(_v1, _v2, _v4)
          return _v5
        end
      CODE

      builder.mapping_method_definition.must_equal expected
    end
  end
end
