require 'introspection_test_helper'

describe GObjectIntrospection::IInterfaceInfo do
  let(:object_info) { get_introspection_data('GObject', 'TypePlugin') }

  describe '#find_method' do
    it 'finds a method by name string' do
      object_info.find_method('complete_interface_info').wont_be_nil
    end

    it 'finds a method by name symbol' do
      object_info.find_method(:complete_interface_info).wont_be_nil
    end
  end

  describe '#type_name' do
    it 'returns the correct name' do
      object_info.type_name.must_equal 'GTypePlugin'
    end
  end
end
