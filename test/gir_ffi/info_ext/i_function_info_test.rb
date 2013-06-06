require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IFunctionInfo do
  let(:testclass) { Class.new do
    include GirFFI::InfoExt::ICallableInfo
    include GirFFI::InfoExt::IFunctionInfo
  end }
  let(:function_info) { testclass.new }

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
end
