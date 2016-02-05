# frozen_string_literal: true
require 'introspection_test_helper'

describe GObjectIntrospection::IUnionInfo do
  let(:object_info) { get_introspection_data('GLib', 'Mutex') }

  describe '#find_method' do
    it 'finds a method by name string' do
      object_info.find_method('clear').wont_be_nil
    end

    it 'finds a method by name symbol' do
      object_info.find_method(:clear).wont_be_nil
    end
  end
end
