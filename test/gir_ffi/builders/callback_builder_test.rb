# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::Builders::CallbackBuilder do
  let(:builder) { GirFFI::Builders::CallbackBuilder.new callback_info }

  describe "#mapping_method_definition" do
    describe "for a callback with arguments and return value" do
      let(:callback_info) { get_introspection_data "Regress", "TestCallbackFull" }
      it "returns a valid mapping method" do
        expected = <<~CODE
        def self.call_with_argument_mapping(_proc, foo, bar, path)
          _v1 = foo
          _v2 = bar
          _v3 = path.to_utf8
          _v4 = _proc.call(_v1, _v2, _v3)
          return _v4
        end
        CODE

        _(builder.mapping_method_definition).must_equal expected
      end
    end

    describe "for a callback with no arguments or return value" do
      let(:callback_info) { get_introspection_data "Regress", "TestSimpleCallback" }
      it "returns a valid mapping method" do
        expected = <<~CODE
        def self.call_with_argument_mapping(_proc)
          _proc.call()
        end
        CODE

        _(builder.mapping_method_definition).must_equal expected
      end
    end

    describe "for a callback with a closure argument" do
      let(:callback_info) { get_introspection_data "Regress", "TestCallbackUserData" }
      it "returns a valid mapping method" do
        expected = <<~CODE
        def self.call_with_argument_mapping(_proc, user_data)
          _v1 = GirFFI::ArgHelper::OBJECT_STORE.fetch(user_data)
          _v2 = _proc.call(_v1)
          return _v2
        end
        CODE

        _(builder.mapping_method_definition).must_equal expected
      end
    end

    describe "for a callback with one out argument" do
      let(:callback_info) do
        get_introspection_data("GIMarshallingTests",
                               "CallbackOneOutParameter")
      end
      it "returns a valid mapping method" do
        expected = <<~CODE
        def self.call_with_argument_mapping(_proc, a)
          _v1 = a
          _v2 = _proc.call()
          _v1.put_float 0, _v2
        end
        CODE

        _(builder.mapping_method_definition).must_equal expected
      end
    end

    describe "for a callback with an inout array argument" do
      let(:callback_info) do
        get_introspection_data("Regress",
                               "TestCallbackArrayInOut")
      end
      it "returns a valid mapping method" do
        expected = <<~CODE
        def self.call_with_argument_mapping(_proc, ints, length)
          _v1 = length
          _v2 = _v1.get_int32(0)
          _v3 = ints
          _v4 = GirFFI::SizedArray.wrap(:gint32, _v2, _v3.get_pointer(0))
          _v5 = _proc.call(_v4)
          _v1.put_int32 0, _v5.length
          _v3.put_pointer 0, GirFFI::SizedArray.from(:gint32, -1, _v5)
        end
        CODE

        _(builder.mapping_method_definition).must_equal expected
      end
    end

    describe "for a callback with a value in argument" do
      let(:field_info) do
        get_field_introspection_data("GObject",
                                     "ObjectClass", "get_property")
      end
      let(:callback_info) do
        field_info.field_type.interface
      end
      it "returns a valid mapping method" do
        expected = <<~CODE
        def self.call_with_argument_mapping(_proc, object, property_id, value, pspec)
          _v1 = GObject::Object.wrap(object)
          _v2 = property_id
          _v3 = GObject::Value.wrap(value)
          _v4 = GObject::ParamSpec.wrap(pspec)
          _proc.call(_v1, _v2, _v3, _v4)
        end
        CODE

        _(builder.mapping_method_definition).must_equal expected
      end
    end
  end
end
