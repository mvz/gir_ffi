require File.expand_path('test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi/builder/dynamic_type'

describe "GirFFI::Builder::DynamicType" do
  before do
    # Ensure existence of GLocalFile type
    GirFFI.setup :Gio
    Gio.file_new_for_path('/')
  end

  it "builds a class based on a GType" do
    gtype = GObject.type_from_name 'GLocalFile'
    bldr = GirFFI::Builder::DynamicType.new(gtype)
    klass = bldr.build_class
    assert_instance_of Class, klass
  end
end
