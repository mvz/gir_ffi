require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::ArgHelper do
  describe "::ptr_to_typed_array" do
    describe "for pointers to class types" do
      it "reads an array of pointers and wraps each in the class" do
        c = Class.new do
          def self.wrap a; "wrapped: #{a}"; end
        end

        mock(ptr = Object.new).read_array_of_pointer(2) { [:a, :b] }

        result = GirFFI::ArgHelper.ptr_to_typed_array [:pointer, c], ptr, 2

        assert_equal ["wrapped: a", "wrapped: b"], result
      end
    end
  end
end
