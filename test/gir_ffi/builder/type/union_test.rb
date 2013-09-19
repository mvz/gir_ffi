require 'gir_ffi_test_helper'

describe GirFFI::Builder::Type::Union do
  let(:union_info) { get_introspection_data('GObject', 'TypeCValue') }
  let(:builder) { GirFFI::Builder::Type::Union.new union_info }

  describe "#setup_instance_method" do
    it "returns false looking for a method that doesn't exist" do
      builder.setup_instance_method('blub').must_equal false
    end
  end

  describe "#layout_specification" do
    it "returns the correct layout for GObject::TypeCValue" do
      builder.layout_specification.must_equal [:v_int, :int32, 0,
                                               :v_long, :int64, 0,
                                               :v_int64, :int64, 0,
                                               :v_double, :double, 0,
                                               :v_pointer, :pointer, 0]
    end
  end

  describe "#layout_superclass" do
    it "returns FFI::Union" do
      builder.layout_superclass.must_equal FFI::Union
    end
  end
end

