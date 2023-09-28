# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :GTop

# Tests generated methods and functions in the GTop namespace. This namespace
# contains types with bad names, like 'glibtop_cpu'.
describe GTop do
  describe "GTop::Glibtop" do
    it "is a valid struct class" do
      # Superclass is either BoxedBase or StructBase, depending on library
      # versions. This means StructLikeBase is always one of the ancestors.
      assert_descendant_of GirFFI::StructLikeBase, GTop::Glibtop
    end

    it "can be created using Glibtop.init" do
      instance = GTop::Glibtop.init
      _(instance).must_be_kind_of GTop::Glibtop
    end
  end
end
