require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IObjectInfo do
  let(:klass) { Class.new do
    include GirFFI::InfoExt::IObjectInfo
  end }
  let(:object_info) { klass.new }

  describe "#to_ffitype" do
    it "returns :pointer" do
      object_info.to_ffitype.must_equal :pointer
    end
  end
end
