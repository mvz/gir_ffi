require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ICallableInfo do
  let(:klass) {
    Class.new do
      include GirFFI::InfoExt::ICallableInfo
    end
  }
  let(:callable_info) { klass.new }

  describe '#argument_ffi_types' do
    describe 'for a simple callable with several arguments' do
      before do
        stub(arg_info1 = Object.new).to_ffitype { :type1 }
        stub(arg_info2 = Object.new).to_ffitype { :type2 }
        stub(callable_info).args { [arg_info1, arg_info2] }
      end

      it 'returns the ffi types of the arguments' do
        callable_info.argument_ffi_types.must_equal [:type1, :type2]
      end
    end
  end
end
