require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::IFieldInfo do
  let(:klass) {
    Class.new do
      include GirFFI::InfoExt::IFieldInfo
    end
  }
  let(:field_info) { klass.new }
  describe "#layout_specification" do
    it "returns an array of name, typespec and offset" do
      mock(type = Object.new).to_ffitype { :bar }

      mock(field_info).name { "foo" }
      mock(field_info).field_type { type }
      mock(field_info).offset { 0 }

      result = field_info.layout_specification

      assert_equal [:foo, :bar, 0], result
    end

    it "keeps a complex typespec intact" do
      mock(type = Object.new).to_ffitype { [:bar, 2] }

      mock(field_info).name { "foo" }
      mock(field_info).field_type { type }
      mock(field_info).offset { 0 }

      result = field_info.layout_specification

      assert_equal [:foo, [:bar, 2], 0], result
    end
  end
end
