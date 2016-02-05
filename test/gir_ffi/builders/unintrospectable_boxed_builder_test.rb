# frozen_string_literal: true
require 'gir_ffi_test_helper'

GirFFI.setup :GIMarshallingTests

describe GirFFI::Builders::UnintrospectableBoxedBuilder do
  let(:instance) { GIMarshallingTests::PropertiesObject.new }
  let(:property) { instance.object_class.find_property 'some-boxed-glist' }
  let(:gtype) { property.value_type }
  let(:info) { GirFFI::UnintrospectableBoxedInfo.new(gtype) }
  let(:bldr) { GirFFI::Builders::UnintrospectableBoxedBuilder.new(info) }
  let(:klass) { bldr.build_class }

  before do
    skip unless get_property_introspection_data('GIMarshallingTests',
                                                'PropertiesObject',
                                                'some-boxed-glist')
  end

  it 'builds a class' do
    klass.must_be_instance_of Class
  end

  it 'builds a class derived from GirFFI::BoxedBase' do
    klass.ancestors.must_include GirFFI::BoxedBase
  end

  it 'returns the same class when built again' do
    other_bldr = GirFFI::Builders::UnintrospectableBoxedBuilder.new(info)
    other_klass = other_bldr.build_class

    other_klass.must_equal klass
  end
end
