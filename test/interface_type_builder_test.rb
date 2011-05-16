require File.expand_path('test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Interface do
  before do
    info = get_function_introspection_data 'GObject', 'TypePlugin'
    @bldr = GirFFI::Builder::Type::Interface.new info
  end

  it "builds the interface as a module" do
    iface = @bldr.build_class
    assert_instance_of Module, iface
  end
end
