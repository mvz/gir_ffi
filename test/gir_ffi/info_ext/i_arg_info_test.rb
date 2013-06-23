require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IArgInfo do
  let(:klass) { Class.new do
    include GirFFI::InfoExt::IArgInfo
  end }
  let(:arg_info) { klass.new }

  describe "#cast_signal_argument" do
    describe "with info for an enum" do
      before do
        enuminfo = get_introspection_data 'GLib', 'DateMonth'
        stub(type_info = Object.new).interface { enuminfo }
        stub(type_info).tag { :interface }
        stub(arg_info).argument_type { type_info }
      end

      it "casts an integer to its enum symbol" do
        res = arg_info.cast_signal_argument 7
        assert_equal :july, res
      end
    end

    describe "with info for an interface" do
      before do
        ifaceinfo = get_introspection_data 'Regress', 'TestInterface'
        stub(type_info = Object.new).interface { ifaceinfo }
        stub(type_info).tag { :interface }
        stub(arg_info).argument_type { type_info }
      end

      it "casts the argument by calling #to_object on it" do
        mock(ptr = Object.new).to_object { "good-result" }
        res = arg_info.cast_signal_argument ptr
        res.must_equal "good-result"
      end
    end
  end
end
