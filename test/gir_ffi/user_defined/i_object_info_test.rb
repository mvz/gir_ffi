require 'gir_ffi_test_helper'

describe GirFFI::UserDefined::IObjectInfo do
  it "has the attribute #properties" do
    inf = GirFFI::UserDefined::IObjectInfo.new
    inf.properties.must_equal []
    inf.properties << :foo
    inf.properties.must_equal [:foo]
    inf.properties = [:bar, :baz]
    inf.properties.must_equal [:bar, :baz]
  end

  it "derives from GirFFI::UserDefined::IRegisteredTypeInfo" do
    inf = GirFFI::UserDefined::IObjectInfo.new
    inf.must_be_kind_of GirFFI::UserDefined::IRegisteredTypeInfo
  end
end

