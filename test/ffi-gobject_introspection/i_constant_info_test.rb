# frozen_string_literal: true

require 'introspection_test_helper'

describe GObjectIntrospection::IConstantInfo do
  describe 'for GLib::USEC_PER_SEC, a constant of type :gint32' do
    let(:constant_info) { get_introspection_data 'GLib', 'USEC_PER_SEC' }

    it 'returns :gint32 as its type' do
      assert_equal :gint32, constant_info.constant_type.tag
    end

    it 'returns 1_000_000 as its value' do
      assert_equal 1_000_000, constant_info.value
    end
  end

  describe 'for GLib::SOURCE_CONTINUE, a constant of type :gboolean' do
    let(:constant_info) { get_introspection_data 'GLib', 'SOURCE_CONTINUE' }

    before do
      skip unless constant_info
    end

    it 'returns :gboolean as its type' do
      assert_equal :gboolean, constant_info.constant_type.tag
    end

    it 'returns true as its value' do
      assert_equal true, constant_info.value
    end
  end
end
