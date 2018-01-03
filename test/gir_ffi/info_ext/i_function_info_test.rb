# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IFunctionInfo do
  let(:info_class) do
    Class.new do
      include GirFFI::InfoExt::ICallableInfo
      include GirFFI::InfoExt::IFunctionInfo
    end
  end
  let(:function_info) { info_class.new }

  describe '#argument_ffi_types' do
    before do
      allow(arg_info1 = Object.new).to receive(:to_ffi_type).and_return :type1
      allow(arg_info2 = Object.new).to receive(:to_ffi_type).and_return :type2
      allow(function_info).to receive(:args).and_return [arg_info1, arg_info2]
    end

    describe 'for a simple function with several arguments' do
      before do
        allow(function_info).to receive(:method?).and_return false
        allow(function_info).to receive(:throws?).and_return false
      end

      it 'returns the ffi types of the arguments' do
        function_info.argument_ffi_types.must_equal [:type1, :type2]
      end
    end

    describe 'for a throwing function with several arguments' do
      before do
        allow(function_info).to receive(:method?).and_return false
        allow(function_info).to receive(:throws?).and_return true
      end

      it 'appends :pointer to represent the error argument' do
        function_info.argument_ffi_types.must_equal [:type1, :type2, :pointer]
      end
    end

    describe 'for a method with several arguments' do
      before do
        allow(function_info).to receive(:method?).and_return true
        allow(function_info).to receive(:throws?).and_return false
      end

      it 'prepends :pointer to represent the method reciever' do
        function_info.argument_ffi_types.must_equal [:pointer, :type1, :type2]
      end
    end

    describe 'for a throwing method with several arguments' do
      before do
        allow(function_info).to receive(:method?).and_return true
        allow(function_info).to receive(:throws?).and_return true
      end

      it 'adds :pointer for both the reciever and the error argument' do
        function_info.argument_ffi_types.must_equal [:pointer, :type1, :type2, :pointer]
      end
    end
  end

  describe '#return_ffi_type' do
    it 'returns the ffi type of the return type' do
      allow(return_type_info = Object.new).to receive(:to_ffi_type).and_return :some_type
      allow(function_info).to receive(:return_type).and_return return_type_info

      function_info.return_ffi_type.must_equal :some_type
    end
  end
end
