# frozen_string_literal: true

require "gir_ffi_test_helper"
require "gir_ffi/user_defined_property_info"

describe GirFFI::UserDefinedPropertyInfo do
  let(:pspec) do
    GObject.param_spec_int("foo-bar", "foo bar",
                           "Foo Bar",
                           1, 3, 2,
                           readable: true, writable: true)
  end
  let(:container) { Object.new }
  let(:info) { GirFFI::UserDefinedPropertyInfo.new pspec, container, 24 }

  describe "#param_spec" do
    it "returns the passed in parameter specification" do
      _(info.param_spec).must_equal pspec
    end
  end

  describe "#name" do
    it "returns the accessor name from the parameter specification" do
      _(info.name).must_equal "foo_bar"
    end
  end

  describe "#ffi_type" do
    it "returns the ffi type corresponding to the type tag" do
      _(info.ffi_type).must_equal :int
    end
  end

  describe "#field_type.tag" do
    it "returns the mapped type symbol" do
      _(info.field_type.tag).must_equal :gint
    end
  end
end
