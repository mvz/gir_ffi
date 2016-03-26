# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GirFFI::Builders::UnionBuilder do
  let(:union_info) { get_introspection_data('GObject', 'TypeCValue') }
  let(:builder) { GirFFI::Builders::UnionBuilder.new union_info }

  describe '#setup_instance_method' do
    it "returns nil looking for a method that doesn't exist" do
      builder.setup_instance_method('blub').must_be_nil
    end
  end

  describe '#layout_specification' do
    it 'returns the correct layout for GObject::TypeCValue' do
      long_type = FFI.type_size(:long) == 8 ? :int64 : :int32
      builder.layout_specification.must_equal [:v_int, :int32, 0,
                                               :v_long, long_type, 0,
                                               :v_int64, :int64, 0,
                                               :v_double, :double, 0,
                                               :v_pointer, :pointer, 0]
    end
  end

  describe '#layout_superclass' do
    it 'returns GirFFI::Union' do
      builder.layout_superclass.must_equal GirFFI::Union
    end
  end
end
