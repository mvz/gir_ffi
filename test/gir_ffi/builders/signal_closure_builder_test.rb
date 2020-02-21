# frozen_string_literal: true

require "gir_ffi_test_helper"

describe GirFFI::Builders::SignalClosureBuilder do
  let(:builder) { GirFFI::Builders::SignalClosureBuilder.new signal_info }

  describe "#build_class" do
    let(:signal_info) do
      get_signal_introspection_data "Regress", "TestObj", "test"
    end

    it "builds a descendant of RubyClosure" do
      klass = builder.build_class
      _(klass.superclass).must_equal GObject::RubyClosure
    end
  end

  describe "#marshaller_definition" do
    describe "for a signal with no arguments or return value" do
      let(:signal_info) do
        get_signal_introspection_data "Regress", "TestObj", "test"
      end

      it "returns a valid marshaller converting only the receiver" do
        expected = <<~CODE
          def self.marshaller(closure, return_value, param_values, _invocation_hint, _marshal_data)
            _instance = param_values.first.get_value_plain
            _v1 = _instance
            wrap(closure.to_ptr).invoke_block(_v1)
          end
        CODE

        _(builder.marshaller_definition).must_equal expected
      end
    end

    describe "for a signal with an argument and a return value" do
      let(:signal_info) do
        get_signal_introspection_data "Regress", "TestObj", "sig-with-int64-prop"
      end

      it "returns a valid mapping method" do
        expected = <<~CODE
          def self.marshaller(closure, return_value, param_values, _invocation_hint, _marshal_data)
            _instance, i = param_values.map(&:get_value_plain)
            _v1 = _instance
            _v2 = i
            _v3 = wrap(closure.to_ptr).invoke_block(_v1, _v2)
            return_value.set_value _v3
          end
        CODE

        _(builder.marshaller_definition).must_equal expected
      end
    end

    describe "for a signal with an enum argument" do
      let(:signal_info) do
        get_signal_introspection_data "Gio", "MountOperation", "reply"
      end

      it "returns a valid mapping method" do
        expected = <<~CODE
          def self.marshaller(closure, return_value, param_values, _invocation_hint, _marshal_data)
            _instance, result = param_values.map(&:get_value_plain)
            _v1 = _instance
            _v2 = result
            wrap(closure.to_ptr).invoke_block(_v1, _v2)
          end
        CODE

        _(builder.marshaller_definition).must_equal expected
      end
    end

    describe "for a signal with a array plus length arguments" do
      let(:signal_info) do
        get_signal_introspection_data "Regress", "TestObj", "sig-with-array-len-prop"
      end

      it "returns a valid mapping method" do
        expected = <<~CODE
          def self.marshaller(closure, return_value, param_values, _invocation_hint, _marshal_data)
            _instance, arr, len = param_values.map(&:get_value_plain)
            _v1 = _instance
            _v2 = len
            _v3 = GirFFI::SizedArray.wrap(:guint32, _v2, arr)
            wrap(closure.to_ptr).invoke_block(_v1, _v3)
          end
        CODE

        _(builder.marshaller_definition).must_equal expected
      end
    end

    describe "for a signal with a struct argument" do
      let(:signal_info) do
        get_signal_introspection_data "Regress", "TestObj", "test-with-static-scope-arg"
      end

      it "returns a valid mapping method" do
        expected = <<~CODE
          def self.marshaller(closure, return_value, param_values, _invocation_hint, _marshal_data)
            _instance, object = param_values.map(&:get_value_plain)
            _v1 = _instance
            _v2 = Regress::TestSimpleBoxedA.wrap(object)
            wrap(closure.to_ptr).invoke_block(_v1, _v2)
          end
        CODE

        _(builder.marshaller_definition).must_equal expected
      end
    end

    describe "for a signal returning an array of integers" do
      let(:signal_info) do
        get_signal_introspection_data "Regress", "TestObj", "sig-with-intarray-ret"
      end

      it "returns a valid mapping method" do
        expected = <<~CODE
          def self.marshaller(closure, return_value, param_values, _invocation_hint, _marshal_data)
            _instance, i = param_values.map(&:get_value_plain)
            _v1 = _instance
            _v2 = i
            _v3 = wrap(closure.to_ptr).invoke_block(_v1, _v2)
            _v4 = GLib::Array.from(:gint32, _v3)
            return_value.set_value _v4
          end
        CODE

        _(builder.marshaller_definition).must_equal expected
      end
    end

    describe "for a signal returning an string" do
      let(:signal_info) do
        get_signal_introspection_data "Gtk", "Scale", "format-value"
      end

      it "returns a mapping method that passes the string result to return_value directly" \
        do
        expected = <<~CODE
          def self.marshaller(closure, return_value, param_values, _invocation_hint, _marshal_data)
            _instance, value = param_values.map(&:get_value_plain)
            _v1 = _instance
            _v2 = value
            _v3 = wrap(closure.to_ptr).invoke_block(_v1, _v2)
            return_value.set_value _v3
          end
        CODE

        _(builder.marshaller_definition).must_equal expected
      end
    end

    describe "for a signal with GList argument" do
      let(:signal_info) do
        get_signal_introspection_data "Regress", "AnnotationObject", "list-signal"
      end

      it "returns a valid mapping method" do
        expected = <<~CODE
          def self.marshaller(closure, return_value, param_values, _invocation_hint, _marshal_data)
            _instance, list = param_values.map(&:get_value_plain)
            _v1 = _instance
            _v2 = GLib::List.wrap(:utf8, list)
            wrap(closure.to_ptr).invoke_block(_v1, _v2)
          end
        CODE

        _(builder.marshaller_definition).must_equal expected
      end
    end

    describe "for a signal with GError argument" do
      let(:signal_info) do
        get_signal_introspection_data "Regress", "TestObj", "sig-with-gerror"
      end

      it "returns a valid mapping method" do
        skip_below "1.61.1"

        expected = <<~CODE
          def self.marshaller(closure, return_value, param_values, _invocation_hint, _marshal_data)
            _instance, error = param_values.map(&:get_value_plain)
            _v1 = _instance
            _v2 = GLib::Error.wrap(error)
            wrap(closure.to_ptr).invoke_block(_v1, _v2)
          end
        CODE

        _(builder.marshaller_definition).must_equal expected
      end
    end
  end
end
