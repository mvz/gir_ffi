require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

# Tests generated methods and functions in the Gio namespace.
describe "The generated Gio module" do
  setup do
    GirFFI.setup :Gio
  end

  describe "#file_new_for_path, a method returning an interface," do
    it "does not throw an error when generated" do
      assert_nothing_raised {
        Gio.file_new_for_path('/')
      }
    end

    it "returns an object of a more specific class" do
      file = Gio.file_new_for_path('/')
      refute_instance_of Gio::File, file
      assert_includes file.class.ancestors, Gio::File
    end
  end

  describe "the result of #file_new_from_path" do
    before do
      @it = Gio.file_new_for_path('/')
    end

    it "is able to set up a method in a class that is not the first ancestor" do
      anc = @it.class.ancestors
      assert_equal [Gio::File, GObject::Object], anc[1, 2]

      refute_defines_instance_method Gio::File, :get_qdata
      assert_defines_instance_method GObject::Object, :get_qdata

      @it.setup_and_call :get_qdata, 1
    end

    it "knows its GType" do
      instance_gtype = GObject.type_from_instance @it
      @it.class.get_gtype.must_equal instance_gtype
    end
  end

  context "the FileInfo class" do
    context "an instance" do
      setup do
        file = Gio.file_new_for_path('/')
        @fileinfo = file.query_info "*", :none, nil
      end

      should "hava a working #get_attribute_type method" do
        type = @fileinfo.get_attribute_type "standard::display-name"
        assert_equal :string, type
      end
    end
  end

  describe "the action-added signal" do
    before do
      @grp = Gio::SimpleActionGroup.new
    end

    it "correctly passes on the string parameter 'action_name'" do
      a = nil
      GObject.signal_connect @grp, "action-added" do |grp, action_name, user_data|
        a = action_name
      end
      GObject.signal_emit @grp, "action-added", "foo"
      assert_equal "foo", a
    end
  end

  describe "the reply signal" do
    before do
      @mo = Gio::MountOperation.new
    end

    it "correctly passes on the enum parameter 'result'" do
      a = nil
      GObject.signal_connect @mo, "reply" do |mnt, result, user_data|
        a = result
      end
      GObject.signal_emit @mo, "reply", 2
      assert_equal :unhandled, a
    end
  end

  describe "the CharsetConverter class" do
    it "includes two interfaces" do
      klass = Gio::CharsetConverter
      assert_includes klass.ancestors, Gio::Converter
      assert_includes klass.ancestors, Gio::Initable
    end

    it "allows an instance to find the #reset method" do
      cnv = Gio::CharsetConverter.new "utf8", "utf8"
      cnv.reset
      pass
    end
  end
end

