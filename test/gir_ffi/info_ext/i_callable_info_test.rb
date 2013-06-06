require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ICallableInfo do
  let(:testclass) { Class.new do
    include GirFFI::InfoExt::ICallableInfo
  end }
  let(:callable_info) { testclass.new }

  describe "#argument_ffi_types" do
    describe "for a simple callable with several arguments" do
      before do
        stub(arg_info1 = Object.new).to_ffitype { :type1 }
        stub(arg_info2 = Object.new).to_ffitype { :type2 }
        stub(callable_info).args { [arg_info1, arg_info2] }
      end

      it "returns the ffi types of the arguments" do
        callable_info.argument_ffi_types.must_equal [:type1, :type2]
      end
    end
  end

  describe "#return_ffi_type" do
    it "returns the ffi type of the return type" do
      stub(return_type_info = Object.new).to_ffitype { :some_type }
      stub(callable_info).return_type { return_type_info }

      callable_info.return_ffi_type.must_equal :some_type
    end
  end
end

