require File.expand_path('test_helper.rb', File.dirname(__FILE__))

# Tests generated methods and functions in the GIMarshallingTests namespace.
describe "GIMarshallingTests" do
  before do
    GirFFI.setup :GIMarshallingTests
  end

  describe "BoxedStruct" do
    it "is created with #new" do
      bx = GIMarshallingTests::BoxedStruct.new
      assert_instance_of GIMarshallingTests::BoxedStruct, bx
    end

    it "has the method #inv" do
      bx = GIMarshallingTests::BoxedStruct.new
      bx[:long_] = 42
      bx.inv
      pass
    end
  end

  it "has the constant CONSTANT_GERROR_CODE" do
    assert_equal 5, GIMarshallingTests::CONSTANT_GERROR_CODE
  end

  it "has the constant CONSTANT_GERROR_DOMAIN" do
    assert_equal "gi-marshalling-tests-gerror-domain",
      GIMarshallingTests::CONSTANT_GERROR_DOMAIN
  end

  it "has the constant CONSTANT_GERROR_MESSAGE" do
    assert_equal "gi-marshalling-tests-gerror-message",
      GIMarshallingTests::CONSTANT_GERROR_MESSAGE
  end

  it "has the constant CONSTANT_NUMBER" do
    assert_equal 42, GIMarshallingTests::CONSTANT_NUMBER
  end

  it "has the constant CONSTANT_UTF8" do
    assert_equal "const ♥ utf8", GIMarshallingTests::CONSTANT_UTF8
  end
end

