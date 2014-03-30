require 'gir_ffi_test_helper'

describe GirFFI::Builders::SignalBuilder do
  let(:builder) { GirFFI::Builders::SignalBuilder.new signal_info }

  describe "#mapping_method_definition" do
    describe "for a signal with no arguments or return value" do
      let(:signal_info) {
        get_signal_introspection_data "Regress", "TestObj", "test" }

      it "returns a valid mapping method including receiver and user data" do
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, _instance, _user_data)
          _v1 = Regress::TestObj.wrap(_instance)
          _v2 = GirFFI::ArgHelper::OBJECT_STORE.fetch(_user_data)
          _proc.call(_v1, _v2)
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
        def self.call_with_argument_mapping(_proc, _instance, i, _user_data)
          _v1 = Regress::TestObj.wrap(_instance)
          _v2 = i
          _v3 = GirFFI::ArgHelper::OBJECT_STORE.fetch(_user_data)
          _v4 = _proc.call(_v1, _v2, _v3)
          return _v4
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
        def self.call_with_argument_mapping(_proc, _instance, result, _user_data)
          _v1 = Gio::MountOperation.wrap(_instance)
          _v2 = Gio::MountOperationResult.wrap(result)
          _v3 = GirFFI::ArgHelper::OBJECT_STORE.fetch(_user_data)
          _proc.call(_v1, _v2, _v3)
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
        def self.call_with_argument_mapping(_proc, _instance, arr, len, _user_data)
          _v1 = Regress::TestObj.wrap(_instance)
          _v2 = len
          _v3 = GirFFI::ArgHelper::OBJECT_STORE.fetch(_user_data)
          _v4 = GirFFI::SizedArray.wrap(:guint32, _v2, arr)
          _proc.call(_v1, _v4, _v3)
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
        def self.call_with_argument_mapping(_proc, _instance, i, _user_data)
          _v1 = Regress::TestObj.wrap(_instance)
          _v2 = i
          _v3 = GirFFI::ArgHelper::OBJECT_STORE.fetch(_user_data)
          _v4 = _proc.call(_v1, _v2, _v3)
          _v5 = GLib::Array.from(:gint32, _v4)
          return _v5
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end
  end
end
