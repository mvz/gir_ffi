require 'gir_ffi_test_helper'

require 'ffi-gobject'

describe GObject::ObjectClass do
  describe '#list_properties' do
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

  describe '#gtype' do
    it 'returns the correct GType' do
      obj = GIMarshallingTests::OverridesObject.new
      object_class = GObject.object_class_from_instance obj
      object_class.gtype.must_equal GIMarshallingTests::OverridesObject.gtype
    end
  end

  describe '.for_gtype' do
    it 'returns the ObjectClass corresponding to the given type' do
      gtype = GIMarshallingTests::OverridesObject.gtype
      object_class = GObject::ObjectClass.for_gtype(gtype)
      object_class.must_be_instance_of GObject::ObjectClass
      object_class.gtype.must_equal gtype
    end

    it 'caches its result' do
      gtype = GIMarshallingTests::OverridesObject.gtype
      first = GObject::ObjectClass.for_gtype(gtype)
      second = GObject::ObjectClass.for_gtype(gtype)
      second.must_be :eql?, first
    end
  end
end
