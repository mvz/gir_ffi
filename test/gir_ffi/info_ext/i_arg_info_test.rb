require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IArgInfo do
  let(:klass) { Class.new do
    include GirFFI::InfoExt::IArgInfo
  end }
  let(:arg_info) { klass.new }

  it "should have some new tests" do
    skip
  end
end
