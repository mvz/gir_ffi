require 'introspection_test_helper'

describe GObjectIntrospection::IRegisteredTypeInfo do
  describe '#get_type_name' do
    describe 'for an interface' do
      let(:registered_type_info) {
        get_introspection_data('GIMarshallingTests', 'Interface')
      }

      it 'returns interface name' do
        registered_type_info.type_name.must_equal 'GIMarshallingTestsInterface'
      end
    end

    describe 'for a type that is not an interface' do
      let(:registered_type_info) {
        get_introspection_data('GIMarshallingTests', 'Enum')
      }

      it 'returns nil' do
        registered_type_info.type_name.must_be_nil
      end
    end
  end
end
