require 'gir_ffi_test_helper'

describe GirFFI::Builders::InterfaceBuilder do
  describe "#build_class" do
    before do
      info = get_introspection_data 'GObject', 'TypePlugin'
      @bldr = GirFFI::Builders::InterfaceBuilder.new info
      @iface = @bldr.build_class
    end

    it "builds an interface as a module" do
      assert_instance_of Module, @iface
    end

    it "creates methods on the interface" do
      assert_defines_instance_method @iface, :complete_interface_info
    end
  end
end
