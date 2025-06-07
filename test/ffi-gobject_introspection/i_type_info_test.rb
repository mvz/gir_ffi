# frozen_string_literal: true

require "introspection_test_helper"

describe GObjectIntrospection::ITypeInfo do
  describe "#name?" do
    let(:object_info) { get_introspection_data("GIMarshallingTests", "Object") }
    let(:vfunc_info) { object_info.find_vfunc("vfunc_array_out_parameter") }
    let(:arg_info) { vfunc_info.args[0] }
    let(:type_info) { arg_info.argument_type }

    it "raises an error" do
      _(proc { type_info.name }).must_raise RuntimeError
    end
  end

  describe "#interface" do
    describe "for unresolvable interface types" do
      let(:function_info) { get_introspection_data "GObject", "signal_set_va_marshaller" }
      let(:argument_info) { function_info.args.last }
      let(:type_info) { argument_info.argument_type }

      it "returns an IUnresolvableInfo object" do
        # TODO: Find another way to test this
        skip_above "1.80.1", "This function is no longer introspectable"
        result = type_info.interface

        _(result.info_type).must_equal :unresolved
        _(result).must_be_kind_of GObjectIntrospection::IUnresolvedInfo
      end
    end
  end
end
