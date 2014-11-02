require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IUnresolvedInfo do
  let(:klass) { Class.new do
    include GirFFI::InfoExt::IUnresolvedInfo
  end }

  let(:unresolved_info) { klass.new }

  describe "#to_ffitype" do
    it "returns the most generic type" do
      unresolved_info.to_ffitype.must_equal :pointer
    end
  end
end
