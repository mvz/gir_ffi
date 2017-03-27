# frozen_string_literal: true

require 'gir_ffi_test_helper'

GirFFI.setup :Regress

describe GirFFI::Builders::RegisteredTypeBuilder do
  describe '#setup_instance_method' do
    it 'restores a method that was removed' do
      Regress::TestObj.class_eval { remove_method 'instance_method' }

      builder = Regress::TestObj.gir_ffi_builder

      builder.setup_instance_method 'instance_method'

      obj = Regress::TestObj.constructor
      obj.must_respond_to 'instance_method'
    end

    it 'returns the name of the generated method' do
      builder = Regress::TestObj.gir_ffi_builder
      result = builder.setup_instance_method 'instance_method'
      result.must_equal 'instance_method'
    end

    it 'returns the name of the generated method if different from the info name' do
      builder = GLib::IConv.gir_ffi_builder
      result = builder.setup_instance_method ''
      result.must_equal '_'
    end
  end
end
