require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Function do
  describe "#pretty_print" do
    it "delegates to #generate" do
      builder = GirFFI::Builder::Function.new(:info, :libmodule)

      mock(builder).generate { 'result_from_generate' }

      assert_equal "result_from_generate", builder.pretty_print
    end
  end
end




