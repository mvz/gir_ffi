# frozen_string_literal: true

require 'introspection_test_helper'

describe GObjectIntrospection::IObjectInfo do
  let(:object_info) { get_introspection_data('GObject', 'Object') }

  describe '#find_vfunc' do
    it 'finds a vfunc by name string' do
      _(object_info.find_vfunc('finalize')).wont_be_nil
    end

    it 'finds a vfunc by name symbol' do
      _(object_info.find_vfunc(:finalize)).wont_be_nil
    end
  end

  describe '#find_method' do
    it 'finds a method by name string' do
      _(object_info.find_method('bind_property')).wont_be_nil
    end

    it 'finds a method by name symbol' do
      _(object_info.find_method(:bind_property)).wont_be_nil
    end
  end

  describe '#find_property' do
    let(:object_info) { get_introspection_data('GObject', 'Binding') }

    it 'finds a property by name string' do
      _(object_info.find_property('source-property')).wont_be_nil
    end

    it 'finds a property by snake case string' do
      _(object_info.find_property('source_property')).wont_be_nil
    end

    it 'finds a property by name symbol' do
      _(object_info.find_property(:source)).wont_be_nil
    end
  end

  describe '#type_name' do
    it 'returns the correct name' do
      _(object_info.type_name).must_equal 'GObject'
    end
  end
end
