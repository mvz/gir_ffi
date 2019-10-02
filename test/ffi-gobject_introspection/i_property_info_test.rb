# frozen_string_literal: true

require 'introspection_test_helper'

describe GObjectIntrospection::IPropertyInfo do
  describe "for Regress::TestObj's 'double' property" do
    let(:property_info) { get_property_introspection_data 'Regress', 'TestObj', 'double' }

    it 'returns :gdouble as its type' do
      _(property_info.property_type.tag).must_equal :gdouble
    end

    it 'flags the property as readable' do
      _(property_info.readable?).must_equal true
    end

    it 'flags the property as writeable' do
      _(property_info.writeable?).must_equal true
    end

    it 'flags the property as not construct-only' do
      _(property_info.construct_only?).must_equal false
    end
  end

  describe "for GObject::Binding's 'target-property' property" do
    let(:property_info) do
      get_property_introspection_data 'GObject', 'Binding', 'target-property'
    end

    it 'returns :utf8 as its type' do
      _(property_info.property_type.tag).must_equal :utf8
    end

    it 'flags the property as readable' do
      _(property_info.readable?).must_equal true
    end

    it 'flags the property as writeable' do
      _(property_info.writeable?).must_equal true
    end

    it 'flags the property as construct-only' do
      _(property_info.construct_only?).must_equal true
    end
  end
end
