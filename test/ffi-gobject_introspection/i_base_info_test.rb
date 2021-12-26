# frozen_string_literal: true

require "introspection_test_helper"

describe GObjectIntrospection::IBaseInfo do
  let(:described_class) { GObjectIntrospection::IBaseInfo }
  describe "#initialize" do
    it "raises an error if a null pointer is passed" do
      _(proc { described_class.new FFI::Pointer::NULL }).must_raise ArgumentError
    end
  end

  describe "#deprecated?" do
    let(:deprecated_info) { get_introspection_data "Regress", "test_versioning" }
    let(:other_info) { get_introspection_data "Regress", "test_value_return" }

    it "returns true for a deprecated item" do
      _(deprecated_info).must_be :deprecated?
    end

    it "returns false for a non-deprecated item" do
      _(other_info).wont_be :deprecated?
    end
  end

  describe "upon garbage collection" do
    it "reduces the reference count" do
      info = get_introspection_data "Regress", "test_value_return"
      GObjectIntrospection::Lib.g_base_info_ref info.to_ptr
      old_ref_count = info.to_ptr.get_int32(4)
      described_class.send :finalize, info.to_ptr
      _(info.to_ptr.get_int32(4)).must_equal old_ref_count - 1
    end
  end
end
