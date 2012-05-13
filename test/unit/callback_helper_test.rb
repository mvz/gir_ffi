require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))
require "gir_ffi/callback_helper"

describe GirFFI::CallbackHelper do
  describe "::map_single_callback_arg" do
    it "maps a :struct type by building the type and wrapping the argument in it" do
      cinfo = get_introspection_data 'GObject', 'ClosureMarshal'
      ainfo = cinfo.args[0]
      ifinfo = ainfo.argument_type.interface

      assert_equal :struct, ifinfo.info_type

      struct_class = Class.new
      mock(GirFFI::Builder).build_class(ifinfo) { struct_class }
      mock(struct_class).wrap("dummy") { "good-result" }

      r = GirFFI::CallbackHelper.map_single_callback_arg "dummy", ainfo.argument_type

      assert_equal "good-result", r
    end

    it "maps an :interface type by calling #to_object on the argument" do
      cinfo = get_introspection_data 'Gtk', 'CellLayoutDataFunc'
      ainfo = cinfo.args[0]
      ifinfo = ainfo.argument_type.interface

      assert_equal :interface, ifinfo.info_type

      mock(ptr = Object.new).to_object { "good-result" }

      r = GirFFI::CallbackHelper.map_single_callback_arg ptr, ainfo.argument_type

      assert_equal "good-result", r
    end

    it "maps an :object type by calling #to_object on the argument" do
      cinfo = get_introspection_data 'Gtk', 'CellLayoutDataFunc'
      ainfo = cinfo.args[1]
      ifinfo = ainfo.argument_type.interface

      assert_equal :object, ifinfo.info_type

      mock(ptr = Object.new).to_object { "good-result" }

      r = GirFFI::CallbackHelper.map_single_callback_arg ptr, ainfo.argument_type

      assert_equal "good-result", r
    end
  end
end
