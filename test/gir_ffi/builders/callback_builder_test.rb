require 'gir_ffi_test_helper'

describe GirFFI::Builders::CallbackBuilder do
  let(:builder) { GirFFI::Builders::CallbackBuilder.new callback_info }

  describe "#mapping_method_definition" do
    describe "for a callback with arguments and return value" do
      let(:callback_info) { get_introspection_data "Regress", "TestCallbackFull" }
      it "returns a valid mapping method" do
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, foo, bar, path)
          _v1 = foo
          _v2 = bar
          _v3 = path.to_utf8
          _v4 = _proc.call(_v1, _v2, _v3)
          return _v4
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a callback with no arguments or return value" do
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

    describe "for a callback with a closure argument" do
      let(:callback_info) { get_introspection_data "Regress", "TestCallbackUserData" }
      it "returns a valid mapping method" do
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, user_data)
          _v1 = GirFFI::ArgHelper::OBJECT_STORE.fetch(user_data)
          _v2 = _proc.call(_v1)
          return _v2
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end

    describe "for a callback with one out argument" do
      let(:callback_info) { get_introspection_data("GIMarshallingTests",
                                                   "CallbackOneOutParameter") }
      it "returns a valid mapping method" do
        expected = <<-CODE.reset_indentation
        def self.call_with_argument_mapping(_proc, a)
          _v1 = GirFFI::InOutPointer.new(:gfloat, a)
          _v2 = _proc.call()
          _v1.set_value _v2
        end
        CODE

        builder.mapping_method_definition.must_equal expected
      end
    end
  end
end
