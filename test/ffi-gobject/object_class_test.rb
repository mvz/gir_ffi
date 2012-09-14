require 'gir_ffi_test_helper'

require 'ffi-gobject'

describe GObject::ObjectClass do
  describe "#list_properties" do
    it "returns GIMarshallingTests::OverridesObject's properties" do
      obj = GIMarshallingTests::OverridesObject.new
      object_class = GObject.object_class_from_instance obj

      info = get_introspection_data 'GIMarshallingTests', 'OverridesObject'
      expected_props = info.properties.map(&:name)
      expected_props += info.parent.properties.map(&:name)

      props = object_class.list_properties
      prop_names = props.map(&:get_name)

      prop_names.sort.must_equal expected_props.sort
    end
  end
end
