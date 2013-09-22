require 'gir_ffi_test_helper'

describe GirFFI::Builders::UnintrospectableBuilder do
  describe "building the GLocalFile type" do
    before do
      # Ensure existence of GLocalFile type
      GirFFI.setup :Gio
      unless Gio::Lib.respond_to? :g_file_new_for_path
        Gio.setup_method "file_new_for_path"
      end
      ptr = GirFFI::InPointer.from :utf8, '/'
      Gio::Lib.g_file_new_for_path(ptr)

      @gtype = GObject.type_from_name 'GLocalFile'
      @info = GirFFI::UnintrospectableTypeInfo.new(@gtype)
      @bldr = GirFFI::Builders::UnintrospectableBuilder.new(@info)
      @klass = @bldr.build_class
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

    it "returns the same class when built again" do
      other_bldr = GirFFI::Builders::UnintrospectableBuilder.new(@info)
      other_klass = other_bldr.build_class

      assert_equal @klass, other_klass
    end

    describe "its #find_signal method" do
      it "raises correct error for a signal that doesn't exist" do
        msg = nil
        begin
          @bldr.find_signal "foo"
        rescue RuntimeError => e
          msg = e.message
        end
        assert_match(/^Signal/, msg)
      end
    end
  end
end
