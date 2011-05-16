require File.expand_path('test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi/builder/dynamic_type'

describe "GirFFI::Builder::DynamicType" do
  describe "building the GLocalFile type" do
    before do
      # Ensure existence of GLocalFile type
      GirFFI.setup :Gio
      Gio.gir_ffi_builder.setup_function "file_new_for_path"
      ptr = GirFFI::ArgHelper.utf8_to_inptr '/'
      Gio::Lib.g_file_new_for_path(ptr)

      @gtype = GObject.type_from_name 'GLocalFile'
      bldr = GirFFI::Builder::DynamicType.new(@gtype)
      @klass = bldr.build_class
    end

    it "builds a class" do
      assert_instance_of Class, @klass
    end

    it "builds a class derived from GObject::Object" do
      assert_includes @klass.ancestors, GObject::Object
    end

    it "builds a class derived from Gio::File" do
      assert_includes @klass.ancestors, Gio::File
    end
  end
end
