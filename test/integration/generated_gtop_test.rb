# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :GTop

# Tests generated methods and functions in the GTop namespace. This namespace
# contains types with bad names, like 'glibtop_cpu'.
describe "The generated GTop module" do
  describe "Glibtop" do
    it "is a valid struct class" do
      # Superclass is either BoxedBase or StructBase, depending on library
      # versions. This means StructBase is always one of the ancestors.
      assert GTop::Glibtop < GirFFI::StructBase
    end

    it "can be created using Glibtop.init" do
      instance = GTop::Glibtop.init
      _(instance).must_be_kind_of GTop::Glibtop
    end
  end
end
