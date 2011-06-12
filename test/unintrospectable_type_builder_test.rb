require File.expand_path('test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Unintrospectable do
  describe "building the GLocalFile type" do
    before do
      # Ensure existence of GLocalFile type
      GirFFI.setup :Gio
      unless Gio::Lib.respond_to? :g_file_new_for_path
        Gio.gir_ffi_setup_function "file_new_for_path"
      end
      ptr = GirFFI::ArgHelper.utf8_to_inptr '/'
      Gio::Lib.g_file_new_for_path(ptr)

      @gtype = GObject.type_from_name 'GLocalFile'
      @bldr = GirFFI::Builder::Type::Unintrospectable.new(@gtype)
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
      other_bldr = GirFFI::Builder::Type::Unintrospectable.new(@gtype)
      other_klass = other_bldr.build_class

      assert_equal @klass, other_klass
    end

    describe "its #find_signal method" do
      it "works for a signal that doesn't exist" do
        assert_nil @bldr.find_signal "foo"
      end
    end
  end
end
