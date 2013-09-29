require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ISignalInfo do
  let(:klass) { Class.new do
    include GirFFI::InfoExt::ICallableInfo
    include GirFFI::InfoExt::ISignalInfo
  end }
  let(:signal_info) { klass.new }

  describe "#arguments_to_gvalue_array" do
    let(:object) { Regress::TestSubObj.new }
    let(:boxed) { Regress::TestSimpleBoxedA.const_return }
    let(:signal_info) { Regress::TestSubObj.find_signal "test-with-static-scope-arg" }
    let(:result) { signal_info.arguments_to_gvalue_array(object, boxed) }

    it "wraps its arguments in a GObject::ValueArray" do
      result.must_be_instance_of GObject::ValueArray
      result.n_values.must_equal 2
    end

    it "correctly wraps :object" do
      result.get_nth(0).get_value.must_equal object
    end

    it "correctly wraps :struct" do
      result_boxed = result.get_nth(1).get_value
      result_boxed.some_int8.must_equal boxed.some_int8
      result_boxed.some_int.must_equal boxed.some_int
    end
  end

  describe "#return_ffi_type" do
    # FIXME: This is needed because callbacks are limited in the accepted
    # types. This should be fixed in FFI.
    it "returns :bool for the :gboolean type" do
      stub(return_type_info = Object.new).to_ffitype { GLib::Boolean }
      stub(signal_info).return_type { return_type_info }

      signal_info.return_ffi_type.must_equal :bool
    end
  end
end
