require 'gir_ffi_test_helper'

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

  describe "#element_type" do
    it "returns the element type for lists" do
      testclass = Class.new do
        include GirFFI::InfoExt::ITypeInfo

        def tag; :glist; end

        def param_type num
          case num
          when 0 then :foo
          else :void
          end
        end
      end

      type_info = testclass.new
      result = type_info.element_type
      result.must_equal :foo
    end

    it "returns the key and value types for ghashes" do
      testclass = Class.new do
        include GirFFI::InfoExt::ITypeInfo

        def tag; :ghash; end

        def param_type num
          case num
          when 0 then :foo
          when 1 then :bar
          else :void
          end
        end
      end

      type_info = testclass.new
      result = type_info.element_type
      result.must_equal [:foo, :bar]
    end

    it "returns nil for other types" do
      testclass = Class.new do
        include GirFFI::InfoExt::ITypeInfo

        def tag; :gfoo; end

        def param_type num; :void; end
      end

      type_info = testclass.new
      result = type_info.element_type
      result.must_be_nil
    end
  end
end
