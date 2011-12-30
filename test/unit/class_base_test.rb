require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::ClassBase do
  describe "a simple descendant" do
    before do
      @klass = Class.new GirFFI::ClassBase
    end

    it "has #from as a pass-through method" do
      result = @klass.from :foo
      result.must_equal :foo
    end
  end
end
