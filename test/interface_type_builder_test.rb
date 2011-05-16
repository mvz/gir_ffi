require File.expand_path('test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Interface do
  before do
    info = get_function_introspection_data 'GObject', 'TypePlugin'
    @bldr = GirFFI::Builder::Type::Interface.new info
    @iface = @bldr.build_class
  end

  it "builds an interface as a module" do
    assert_instance_of Module, @iface
  end

  it "creates methods on the interface" do
    assert_includes @iface.instance_methods, 'complete_interface_info'
  end
end
