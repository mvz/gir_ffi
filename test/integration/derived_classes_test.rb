require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

# Tests deriving Ruby classes from GObject classes.
describe "Class derivation" do
  before do
    save_module :GIMarshallingTests
    GirFFI.setup :GIMarshallingTests
  end

  describe "with an interface mixed in" do
    before do
      @klass = Class.new GIMarshallingTests::OverridesObject
      @klass.send :include, GIMarshallingTests::Interface
    end

    it "finds class methods in the superclass" do
      @klass.returnv
    end

    it "finds instance methods in the superclass" do
      obj = @klass.new
      result = obj.method
      result.must_equal 42
    end
  end

  after do
    restore_module :GIMarshallingTests
  end
end

