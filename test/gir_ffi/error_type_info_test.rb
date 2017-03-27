# frozen_string_literal: true

require 'gir_ffi_test_helper'
require 'gir_ffi/error_type_info'

describe GirFFI::ErrorTypeInfo do
  let(:instance) { GirFFI::ErrorTypeInfo.new }

  describe '#array_length' do
    it 'returns the correct value' do
      instance.array_length.must_equal(-1)
    end
  end

  describe '#tag_or_class' do
    it 'returns the correct value' do
      instance.tag_or_class.must_equal [:pointer, :error]
    end
  end

  describe '#pointer?' do
    it 'returns the correct value' do
      instance.pointer?.must_equal true
    end
  end

  describe '#flattened_tag' do
    it 'returns the correct value' do
      instance.flattened_tag.must_equal :error
    end
  end

  describe '#extra_conversion_arguments' do
    it 'returns the correct value' do
      instance.extra_conversion_arguments.must_equal []
    end
  end

  describe '#argument_class_name' do
    it 'returns the correct value' do
      instance.argument_class_name.must_equal 'GLib::Error'
    end
  end

  describe '#needs_ruby_to_c_conversion_for_callbacks?' do
    it 'returns the correct value' do
      instance.needs_ruby_to_c_conversion_for_callbacks?.must_equal true
    end
  end
end
