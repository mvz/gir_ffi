require 'gir_ffi_test_helper'

describe GirFFI::Builders::CallbackBuilder do
  let(:builder) { GirFFI::Builders::CallbackBuilder.new callback_info }

  describe "#mapping_method_definition" do
    describe "for Regress::TestCallbackFull" do
      let(:callback_info) { get_introspection_data "Regress", "TestCallbackFull" }
      it "returns a valid mapping method" do
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

    describe "for Regress::TestSimpleCallback" do
      let(:callback_info) { get_introspection_data "Regress", "TestSimpleCallback" }
      it "returns a valid mapping method" do
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc)
          _proc.call()
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end
  end
end
