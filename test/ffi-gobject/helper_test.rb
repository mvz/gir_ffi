require 'gir_ffi_test_helper'

describe GObject::Helper do
  before do
    GirFFI.setup :Regress
  end

  describe "#signal_argument_to_gvalue" do
    it "maps a :utf8 argument to a string-valued GValue" do
      stub(arg_t = Object.new).g_type { GObject::TYPE_STRING }
      stub(info = Object.new).argument_type { arg_t }
      val = GObject::Helper.signal_argument_to_gvalue(info, "foo")
      assert_instance_of GObject::Value, val
      assert_equal "foo", val.get_string
    end
  end
end
