require File.expand_path('test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi/builder/dynamic_type'

describe "GirFFI::Builder::DynamicType" do
  describe "building the GLocalFile type" do
    before do
      # Ensure existence of GLocalFile type
      GirFFI.setup :Gio
      Gio.file_new_for_path('/')

      @gtype = GObject.type_from_name 'GLocalFile'
    end

    it "builds a class" do
      bldr = GirFFI::Builder::DynamicType.new(@gtype)
      klass = bldr.build_class
      assert_instance_of Class, klass
    end

    it "builds a class derived from GObject::Object" do
      bldr = GirFFI::Builder::DynamicType.new(@gtype)
      klass = bldr.build_class
      assert_includes klass.ancestors, GObject::Object
    end
  end
end
