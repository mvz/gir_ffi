# frozen_string_literal: true

require "gir_ffi_test_helper"

require "ffi-gobject"
describe GObject::ParamSpec do
  let(:pspec) do
    GObject.param_spec_int("foo-bar", "foo bar",
                           "Foo Bar",
                           1, 3, 2,
                           readable: true, writable: true)
  end
  let(:pspec_struct) { GObject::ParamSpec::Struct.new(pspec.to_ptr) }

  describe "#ref" do
    it "increases the ref count" do
      old = pspec_struct[:ref_count]
      pspec.ref

      _(pspec_struct[:ref_count]).must_equal old + 1
    end
  end

  describe "#accessor_name" do
    it "returns a safe ruby method name" do
      _(pspec.accessor_name).must_equal "foo_bar"
    end
  end

  it "cannot be instantiated directly" do
    _(proc { GObject::ParamSpec.new }).must_raise NoMethodError
  end
end
