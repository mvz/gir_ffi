require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::HashTableElementTypeProvider do
  describe "#elm_t" do
    it "returns a string with an array of the first two subtype tags" do
      builder = Object.new
      builder.extend GirFFI::Builder::HashTableElementTypeProvider

      mock(type_info = Object.new).element_type { [:foo, :bar] }
      mock(builder).type_info { type_info }

      assert_equal "[:foo, :bar]", builder.elm_t
    end
  end
end

