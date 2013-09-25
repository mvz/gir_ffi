require 'gir_ffi_test_helper'

describe GirFFI::Builders::SignalBuilder do
  let(:builder) { GirFFI::Builders::SignalBuilder.new signal_info }

  describe "#mapping_method_definition" do
    describe "for a signal with no arguments or return value" do
      let(:signal_info) {
        get_signal_introspection_data "Regress", "TestObj", "test" }

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
