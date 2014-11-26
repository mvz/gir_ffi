require 'gir_ffi_test_helper'

describe GirFFI::Builders::InterfaceBuilder do
  let(:interface_builder) {
    GirFFI::Builders::InterfaceBuilder.new(
    get_introspection_data('Regress', 'TestInterface'))
  }

  describe '#build_class' do
    before do
      info = get_introspection_data 'GObject', 'TypePlugin'
      @bldr = GirFFI::Builders::InterfaceBuilder.new info
      @iface = @bldr.build_class
    end

    it 'builds an interface as a module' do
      assert_instance_of Module, @iface
    end

    it 'creates methods on the interface' do
      assert_defines_instance_method @iface, :complete_interface_info
    end
  end

  describe '#interface_struct' do
    it 'returns the interface struct type' do
      interface_builder.interface_struct.must_equal Regress::TestInterfaceIface
    end
  end
end
