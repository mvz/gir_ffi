require 'gir_ffi_test_helper'

describe GirFFI::Builders::ModuleBuilder do
  describe "#build_namespaced_class" do
    it "raises a clear error if the named class does not exist" do
      gir = GObjectIntrospection::IRepository.default
      stub(gir).require("Foo", nil) {}

      builder = GirFFI::Builders::ModuleBuilder.new "Foo"

      mock(gir).find_by_name("Foo", "Bar") { nil }

      assert_raises NameError do
        builder.build_namespaced_class :Bar
      end
    end
  end
end
