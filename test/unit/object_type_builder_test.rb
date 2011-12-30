require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Object do
  before do
    GirFFI.setup :Regress
  end

  describe "#setup_method" do
    it "sets up singleton methods defined in a class's parent" do
      info = get_introspection_data 'Regress', 'TestSubObj'
      assert_nil info.find_method "static_method"
      parent = info.parent
      assert_not_nil parent.find_method "static_method"

      b = GirFFI::Builder::Type::Object.new(info)
      result = b.setup_method "static_method"
      assert_equal true, result
    end
  end

  describe "#find_property" do
    it "finds a property specified on the class itself" do
      builder = GirFFI::Builder::Type::Object.new(
        get_introspection_data('Regress', 'TestObj'))
      prop = builder.find_property("int")
      assert_equal "int", prop.name
    end

    it "finds a property specified on the parent class" do
      builder = GirFFI::Builder::Type::Object.new(
        get_introspection_data('Regress', 'TestSubObj'))
      prop = builder.find_property("int")
      assert_equal "int", prop.name
    end

    it "raises an error if the property is not found" do
      builder = GirFFI::Builder::Type::Object.new(
        get_introspection_data('Regress', 'TestSubObj'))
      assert_raises RuntimeError do
        builder.find_property("this-property-does-not-exist")
      end
    end
  end
end
