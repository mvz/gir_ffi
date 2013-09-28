require 'gir_ffi_test_helper'

describe GirFFI::Builders::SignalBuilder do
  let(:builder) { GirFFI::Builders::SignalBuilder.new signal_info }

  describe "#mapping_method_definition" do
    describe "for a signal with no arguments or return value" do
      let(:signal_info) {
        get_signal_introspection_data "Regress", "TestObj", "test" }

      it "returns a valid mapping method including receiver and user data" do
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _v1, _v2)
          _v3 = ::Regress::TestObj.wrap(_v1)
          _v4 = GirFFI::ArgHelper::OBJECT_STORE[_v2.address]
          _proc.call(_v3, _v4)
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a signal with an argument and a return value" do
      let(:signal_info) {
        get_signal_introspection_data "Regress", "TestObj", "sig-with-int64-prop" }

      it "returns a valid mapping method" do
        skip unless signal_info

        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _v1, _v2, _v3)
          _v4 = ::Regress::TestObj.wrap(_v1)
          _v5 = GirFFI::ArgHelper::OBJECT_STORE[_v3.address]
          _v6 = _proc.call(_v4, _v2, _v5)
          return _v6
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a signal with an enum argument" do
      let(:signal_info) {
        get_signal_introspection_data "Gio", "MountOperation", "reply" }

      it "returns a valid mapping method" do
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _v1, _v2, _v3)
          _v4 = ::Gio::MountOperation.wrap(_v1)
          _v5 = ::Gio::MountOperationResult[_v2]
          _v6 = GirFFI::ArgHelper::OBJECT_STORE[_v3.address]
          _proc.call(_v4, _v5, _v6)
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end
  end
end
