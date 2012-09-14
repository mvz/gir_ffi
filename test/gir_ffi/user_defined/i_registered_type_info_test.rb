require 'gir_ffi_test_helper'

describe GirFFI::UserDefined::IRegisteredTypeInfo do
  it "derives from GirFFI::UserDefined::IBaseInfo" do
    inf = GirFFI::UserDefined::IRegisteredTypeInfo.new
    inf.must_be_kind_of GirFFI::UserDefined::IBaseInfo
  end
end


