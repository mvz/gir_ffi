require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IFunctionInfo do
  let(:klass) { Class.new do
    include GirFFI::InfoExt::ICallableInfo
    include GirFFI::InfoExt::IFunctionInfo
  end }
  let(:function_info) { klass.new }

  describe "#argument_ffi_types" do
    before do
      stub(arg_info1 = Object.new).to_ffitype { :type1 }
      stub(arg_info2 = Object.new).to_ffitype { :type2 }
      stub(function_info).args { [arg_info1, arg_info2] }
    end

    describe "for a simple function with several arguments" do
      before do
        stub(function_info).method? { false }
        stub(function_info).throws? { false }
      end

      it "returns the ffi types of the arguments" do
        function_info.argument_ffi_types.must_equal [:type1, :type2]
      end
    end

    describe "for a throwing function with several arguments" do
      before do
        stub(function_info).method? { false }
        stub(function_info).throws? { true }
      end

      it "appends :pointer to represent the error argument" do
        function_info.argument_ffi_types.must_equal [:type1, :type2, :pointer]
      end
    end

    describe "for a method with several arguments" do
      before do
        stub(function_info).method? { true }
        stub(function_info).throws? { false }
      end

      it "prepends :pointer to represent the method reciever" do
        function_info.argument_ffi_types.must_equal [:pointer, :type1, :type2]
      end
    end

    describe "for a throwing method with several arguments" do
      before do
        stub(function_info).method? { true }
        stub(function_info).throws? { true }
      end

      it "adds :pointer for both the reciever and the error argument" do
        function_info.argument_ffi_types.must_equal [:pointer, :type1, :type2, :pointer]
      end
    end
  end

  describe "#return_ffi_type" do
    it "returns the ffi type of the return type" do
      stub(return_type_info = Object.new).to_ffitype { :some_type }
      stub(function_info).return_type { return_type_info }

      function_info.return_ffi_type.must_equal :some_type
    end
  end
end
