require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IFieldInfo do
  describe "#layout_specification" do
    it "returns an array of name, typespec and offset" do
      testclass = Class.new do
        include GirFFI::InfoExt::IFieldInfo
      end

      mock(type = Object.new).to_ffitype { :bar }

      field = testclass.new
      mock(field).name { "foo" }
      mock(field).field_type { type }
      mock(field).offset { 0 }

      result = field.layout_specification

      assert_equal [:foo, :bar, 0], result
    end

    it "keeps a complex typespec intact" do
      testclass = Class.new do
        include GirFFI::InfoExt::IFieldInfo
      end

      mock(type = Object.new).to_ffitype { [:bar, 2] }

      field = testclass.new
      mock(field).name { "foo" }
      mock(field).field_type { type }
      mock(field).offset { 0 }

      result = field.layout_specification

      assert_equal [:foo, [:bar, 2], 0], result
    end
  end
end
