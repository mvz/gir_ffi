require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

# This suite tests extensions to ITypeInfo defined in gir_ffi.
describe GirFFI::InfoExt::ITypeInfo do
  describe "#layout_specification_type" do
    it "returns an array with elements subtype and size for type :array" do
      testclass = Class.new do
        include GirFFI::InfoExt::ITypeInfo
      end

      mock(subtype = Object.new).layout_specification_type { :foo }

      type = testclass.new
      mock(type).array_fixed_size { 2 }
      mock(type).param_type(0) { subtype }

      mock(GirFFI::Builder).itypeinfo_to_ffitype(type) { :array }

      result = type.layout_specification_type

      assert_equal [:foo, 2], result
    end
  end
end
