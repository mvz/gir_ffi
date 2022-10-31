# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :Gio

# Tests generated methods and functions in the Gio namespace.
describe Gio do
  describe "Gio::File" do
    describe "#new_for_path, a method returning an interface," do
      it "returns an object of a more specific class" do
        file = Gio::File.new_for_path("/")
        _(file.class.registered_ancestors)
          .must_equal [file.class, Gio::File, GObject::Object]

        refute_instance_of Gio::File, file
        assert_includes file.class.registered_ancestors, Gio::File
      end
    end
  end

  describe "#file_new_from_path" do
    before do
      @it = Gio.file_new_for_path("/")
    end

    it "returns an object that can set up a method in distant ancestor class" do
      refute_defines_instance_method @it.class, :get_qdata
      refute_defines_instance_method Gio::File, :get_qdata
      assert_defines_instance_method GObject::Object, :get_qdata

      @it.setup_and_call :get_qdata, 1
    end

    it "returns an object that knows its GType" do
      instance_gtype = GObject.type_from_instance @it
      _(@it.class.gtype).must_equal instance_gtype
    end
  end

  describe "Gio::FileInfo" do
    describe "an instance" do
      before do
        file = Gio.file_new_for_path("/")
        @fileinfo = file.query_info "*", :none, nil
      end

      it "has a working #get_attribute_type method" do
        type = @fileinfo.get_attribute_type "standard::display-name"

        assert_equal :string, type
      end
    end
  end

  describe "Gio::SimpleActionGroup" do
    before do
      @grp = Gio::SimpleActionGroup.new
    end

    it "handles the 'action-added' signal" do
      a = nil
      GObject.signal_connect @grp, "action-added" do |_grp, action_name, _user_data|
        a = action_name
      end
      GObject.signal_emit @grp, "action-added", "foo"

      assert_equal "foo", a
    end
  end

  describe "Gio::MountOperation" do
    before do
      @mo = Gio::MountOperation.new
    end

    it "handles the 'reply' signal" do
      a = nil
      GObject.signal_connect @mo, "reply" do |_mnt, result, _user_data|
        a = result
      end
      GObject.signal_emit @mo, "reply", :unhandled

      assert_equal :unhandled, a
    end
  end

  describe "Gio::CharsetConverter" do
    it "includes two interfaces" do
      klass = Gio::CharsetConverter
      _(klass.included_interfaces).must_equal [Gio::Initable, Gio::Converter]
    end

    it "allows an instance to find the #reset method" do
      cnv = Gio::CharsetConverter.new "utf8", "utf8"
      cnv.reset
      pass
    end
  end

  describe "Gio::SocketSourceFunc" do
    it "can be cast to a native function" do
      Gio::SocketSourceFunc.new { |*args| p args }.to_native
    end
  end

  describe "Gio::SimpleAction" do
    let(:simple_action) { Gio::SimpleAction.new("test", "d") }

    it 'can read the property "state-type" with #get_property' do
      _(simple_action.get_property("state-type")).must_be_nil
    end

    it 'can read the property "state-type" with #state_type' do
      _(simple_action.state_type).must_be_nil
    end

    it 'cannot write the property "state-type" with #state_type=' do
      _(simple_action).wont_respond_to :state_type=
    end
  end
end
