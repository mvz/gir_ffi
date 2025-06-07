# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :Regress

describe GirFFI::Builders::TypeBuilder do
  describe "#builder_for" do
    it "returns StructBuilder for metaclasses" do
      info = get_introspection_data("GObject", "InitiallyUnownedClass")
      builder = GirFFI::Builders::TypeBuilder.builder_for(info)

      _(builder).must_be_instance_of GirFFI::Builders::StructBuilder
    end
  end
end
