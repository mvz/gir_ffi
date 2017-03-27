# frozen_string_literal: true

require 'gir_ffi_test_helper'
require 'gir_ffi/user_defined_property_info'

describe GirFFI::UserDefinedPropertyInfo do
  let(:pspec) do
    GObject.param_spec_int('foo-bar', 'foo bar',
                           'Foo Bar',
                           1, 3, 2,
                           readable: true, writable: true)
  end
  let(:info) { GirFFI::UserDefinedPropertyInfo.new pspec }

  describe '#param_spec' do
    it 'returns the passed in parameter specification' do
      info.param_spec.must_equal pspec
    end
  end

  describe '#name' do
    it 'returns the name retrieved from the parameter specification' do
      info.name.must_equal 'foo-bar'
    end
  end

  describe '#ffi_type' do
    it 'returns the ffi type corresponding to the type tag' do
      info.ffi_type.must_equal :int
    end
  end

  describe '#type_tag' do
    it 'returns the mapped type symbol' do
      info.type_tag.must_equal :gint
    end
  end
end
