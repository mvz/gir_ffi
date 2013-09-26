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

    describe "for a signal with an argument and a return value" do
      let(:signal_info) {
        get_signal_introspection_data "Regress", "TestObj", "sig-with-int64-prop" }

      it "returns a valid mapping method" do
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _v1)
          _v2 = _proc.call(_v1)
          return _v2
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end
  end
end
