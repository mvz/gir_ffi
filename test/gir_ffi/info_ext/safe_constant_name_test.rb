require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::SafeConstantName do
  let(:testclass) { Class.new do
    include GirFFI::InfoExt::SafeConstantName
  end }
  let(:info) { testclass.new }

  describe "#safe_name" do
    it "makes names starting with an underscore safe" do
      mock(info).name { "_foo" }

      assert_equal "Private___foo", info.safe_name
    end
  end
end
