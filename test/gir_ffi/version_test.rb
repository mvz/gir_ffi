require 'gir_ffi_test_helper'

describe GirFFI::VERSION do
  it "is set to a valid version number" do
    GirFFI::VERSION.must_match(/\d\.\d\.\d/)
  end
end
