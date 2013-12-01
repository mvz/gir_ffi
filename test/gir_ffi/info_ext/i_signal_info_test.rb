require 'gir_ffi_test_helper'

GirFFI.setup :Regress

describe GirFFI::InfoExt::ISignalInfo do
  let(:klass) { Class.new do
    include GirFFI::InfoExt::ICallableInfo
    include GirFFI::InfoExt::ISignalInfo
  end }
  let(:signal_info) { klass.new }

  describe "#arguments_to_gvalues" do
    let(:object) { Regress::TestSubObj.new }
    let(:boxed) { Regress::TestSimpleBoxedA.const_return }
    let(:signal_info) { Regress::TestSubObj.find_signal "test-with-static-scope-arg" }
    let(:result) { signal_info.arguments_to_gvalues(object, [boxed]) }

    it "correctly wraps :object" do
      result[0].get_value.must_equal object
    end

    it "correctly wraps :struct" do
      result_boxed = result[1].get_value
      result_boxed.some_int8.must_equal boxed.some_int8
      result_boxed.some_int.must_equal boxed.some_int
    end
  end

  describe "#return_ffi_type" do
    # NOTE: This is needed because FFI callbacks are limited in the
    # accepted types.
    it "returns :bool for the :gboolean type" do
      stub(return_type_info = Object.new).to_ffitype { GLib::Boolean }
      stub(signal_info).return_type { return_type_info }

      signal_info.return_ffi_type.must_equal :bool
    end
  end
end
