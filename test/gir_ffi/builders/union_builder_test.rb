# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::Builders::UnionBuilder do
  let(:union_info) { get_introspection_data('Regress', 'FooBUnion') }
  let(:builder) { GirFFI::Builders::UnionBuilder.new union_info }

  describe '#setup_instance_method' do
    it "returns nil looking for a method that doesn't exist" do
      _(builder.setup_instance_method('blub')).must_be_nil
    end
  end

  describe '#layout_specification' do
    it 'returns the correct layout for Regress::FooBUnion' do
      _(builder.layout_specification).must_equal [:type, :int32, 0,
                                                  :v, :double, 0,
                                                  :rect, :pointer, 0]
    end
  end

  describe '#layout_superclass' do
    it 'returns GirFFI::Union' do
      _(builder.layout_superclass).must_equal GirFFI::Union
    end
  end
end
