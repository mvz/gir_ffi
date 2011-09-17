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

      r = GirFFI::CallbackHelper.map_single_callback_arg "dummy", ainfo

      assert_equal "good-result", r
    end
  end
end
