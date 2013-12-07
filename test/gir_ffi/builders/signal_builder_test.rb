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
          _v3 = Regress::TestObj.wrap(_v1)
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
        def self.call_with_argument_mapping(_proc, _v1, i, _v2)
          _v3 = Regress::TestObj.wrap(_v1)
          _v4 = GirFFI::ArgHelper::OBJECT_STORE[_v2.address]
          _v5 = _proc.call(_v3, i, _v4)
          return _v5
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
        def self.call_with_argument_mapping(_proc, _v1, result, _v2)
          _v3 = Gio::MountOperation.wrap(_v1)
          _v4 = Gio::MountOperationResult.wrap(result)
          _v5 = GirFFI::ArgHelper::OBJECT_STORE[_v2.address]
          _proc.call(_v3, _v4, _v5)
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a signal with a array plus length arguments" do
      let(:signal_info) {
        get_signal_introspection_data "Regress", "TestObj", "sig-with-array-len-prop" }

      it "returns a valid mapping method" do
        skip unless signal_info

        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _v1, arr, len, _v2)
          _v3 = Regress::TestObj.wrap(_v1)
          _v4 = GirFFI::SizedArray.wrap(:guint32, len, arr)
          _v5 = GirFFI::ArgHelper::OBJECT_STORE[_v2.address]
          _proc.call(_v3, _v4, _v5)
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a signal returning an array of integers" do
      let(:signal_info) {
        get_signal_introspection_data "Regress", "TestObj", "sig-with-intarray-ret" }

      it "returns a valid mapping method" do
        skip unless signal_info

        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _v1, i, _v2)
          _v3 = Regress::TestObj.wrap(_v1)
          _v4 = GirFFI::ArgHelper::OBJECT_STORE[_v2.address]
          _v5 = _proc.call(_v3, i, _v4)
          _v6 = GLib::Array.from(:gint32, _v5)
          return _v6
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end
  end
end
