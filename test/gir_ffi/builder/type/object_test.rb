require 'gir_ffi_test_helper'

describe GirFFI::Builder::Type::Object do
  describe '#find_signal' do
    it 'finds the signal "test" for TestObj' do
      builder = GirFFI::Builder::Type::Object.new get_introspection_data('Regress', 'TestObj')
      sig = builder.find_signal 'test'
      assert_equal 'test', sig.name
    end

    it 'finds the signal "test" for TestSubObj' do
      builder = GirFFI::Builder::Type::Object.new get_introspection_data('Regress', 'TestSubObj')
      sig = builder.find_signal 'test'
      assert_equal 'test', sig.name
    end

    it 'finds the signal "changed" for Gtk::Entry' do
      builder = GirFFI::Builder::Type::Object.new get_introspection_data('Gtk', 'Entry')
      sig = builder.find_signal 'changed'
      assert_equal 'changed', sig.name
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

  describe "#function_definition" do
    before do
      @cbuilder = GirFFI::Builder::Type::Object.new get_introspection_data('Regress', 'TestObj')
      @go = get_method_introspection_data 'Regress', 'TestObj', 'instance_method'
    end

    it "delegates definition to Builder::Function" do
      code = @cbuilder.send :function_definition, @go
      expected = GirFFI::Builder::Function.new(@go, Regress::Lib).generate
      assert_equal cws(expected), cws(code)
    end

  end
end
