# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IFieldInfo do
  let(:info_class) do
    Class.new do
      include GirFFI::InfoExt::IFieldInfo
    end
  end
  let(:field_info) { info_class.new }
  describe '#layout_specification' do
    it 'returns an array of name, typespec and offset' do
      expect(type = Object.new).to receive(:to_ffi_type).and_return :bar

      expect(field_info).to receive(:name).and_return 'foo'
      expect(field_info).to receive(:field_type).and_return type
      expect(field_info).to receive(:offset).and_return 0

      result = field_info.layout_specification

      assert_equal [:foo, :bar, 0], result
    end

    it 'keeps a complex typespec intact' do
      expect(type = Object.new).to receive(:to_ffi_type).and_return [:bar, 2]

      expect(field_info).to receive(:name).and_return 'foo'
      expect(field_info).to receive(:field_type).and_return type
      expect(field_info).to receive(:offset).and_return 0

      result = field_info.layout_specification

      assert_equal [:foo, [:bar, 2], 0], result
    end
  end
end
