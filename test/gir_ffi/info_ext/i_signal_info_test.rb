require 'gir_ffi_test_helper'

GirFFI.setup :Regress

describe GirFFI::InfoExt::ISignalInfo do
  let(:klass) do
    Class.new do
      include GirFFI::InfoExt::ICallableInfo
      include GirFFI::InfoExt::ISignalInfo
    end
  end
  let(:signal_info) { klass.new }

  describe '#arguments_to_gvalues' do
    let(:object) { Regress::TestSubObj.new }
    let(:boxed) { Regress::TestSimpleBoxedA.const_return }
    let(:signal_info) { Regress::TestSubObj.find_signal 'test-with-static-scope-arg' }
    let(:result) { signal_info.arguments_to_gvalues(object, [boxed]) }

    it 'correctly wraps :object' do
      result[0].get_value.must_equal object
    end

    it 'correctly wraps :struct' do
      result_boxed = result[1].get_value
      result_boxed.some_int8.must_equal boxed.some_int8
      result_boxed.some_int.must_equal boxed.some_int
    end
  end
end
