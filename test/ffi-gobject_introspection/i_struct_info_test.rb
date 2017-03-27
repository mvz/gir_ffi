# frozen_string_literal: true

require 'introspection_test_helper'

describe GObjectIntrospection::IStructInfo do
  let(:object_info) { get_introspection_data('GObject', 'Closure') }

  describe '#find_method' do
    it 'finds a method by name string' do
      object_info.find_method('new_simple').wont_be_nil
    end

    it 'finds a method by name symbol' do
      object_info.find_method(:new_simple).wont_be_nil
    end
  end

  describe '#type_name' do
    it 'returns the correct name' do
      object_info.type_name.must_equal 'GClosure'
    end
  end
end
