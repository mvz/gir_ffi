# frozen_string_literal: true
require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ICallableInfo do
  let(:klass) do
    Class.new do
      include GirFFI::InfoExt::ICallableInfo
    end
  end
  let(:callable_info) { klass.new }

  describe '#argument_ffi_types' do
    describe 'for a simple callable with several arguments' do
      before do
        allow(arg_info1 = Object.new).to receive(:to_ffi_type).and_return :type1
        allow(arg_info2 = Object.new).to receive(:to_ffi_type).and_return :type2
        allow(callable_info).to receive(:args).and_return [arg_info1, arg_info2]
      end

      it 'returns the ffi types of the arguments' do
        callable_info.argument_ffi_types.must_equal [:type1, :type2]
      end
    end
  end
end
