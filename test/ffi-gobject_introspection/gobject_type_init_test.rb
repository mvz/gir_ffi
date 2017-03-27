# frozen_string_literal: true

require 'introspection_test_helper'

describe GObjectIntrospection::GObjectTypeInit do
  describe 'Lib' do
    it 'represents the gobject-2.0 library' do
      GObjectIntrospection::GObjectTypeInit::Lib.ffi_libraries.first.name.
        must_match(/gobject-2\.0/)
    end

    it 'provides the g_type_init function' do
      GObjectIntrospection::GObjectTypeInit::Lib.must_respond_to :g_type_init
    end
  end

  describe '.type_init' do
    it 'calls the g_type_init function from the gobject-2.0 library' do
      allow(GObjectIntrospection::GObjectTypeInit::Lib).to receive(:g_type_init)

      GObjectIntrospection::GObjectTypeInit.type_init

      expect(GObjectIntrospection::GObjectTypeInit::Lib).to have_received(:g_type_init)
    end
  end
end
