require 'gir_ffi_test_helper'

describe GirFFI::Builders::ObjectBuilder do
  let(:obj_builder) { GirFFI::Builders::ObjectBuilder.new(
    get_introspection_data('Regress', 'TestObj')) }

  describe '#find_signal' do
    it 'finds the signal "test" for TestObj' do
      builder = GirFFI::Builders::ObjectBuilder.new get_introspection_data('Regress', 'TestObj')
      sig = builder.find_signal 'test'
      assert_equal 'test', sig.name
    end

    it 'finds the signal "test" for TestSubObj' do
      builder = GirFFI::Builders::ObjectBuilder.new get_introspection_data('Regress', 'TestSubObj')
      sig = builder.find_signal 'test'
      assert_equal 'test', sig.name
    end

    it 'finds the signal "changed" for Gtk::Entry' do
      builder = GirFFI::Builders::ObjectBuilder.new get_introspection_data('Gtk', 'Entry')
      sig = builder.find_signal 'changed'
      assert_equal 'changed', sig.name
    end
  end

  describe "#find_property" do
    it "finds a property specified on the class itself" do
      builder = GirFFI::Builders::ObjectBuilder.new(
        get_introspection_data('Regress', 'TestObj'))
      prop = builder.find_property("int")
      assert_equal "int", prop.name
    end

    it "finds a property specified on the parent class" do
      builder = GirFFI::Builders::ObjectBuilder.new(
        get_introspection_data('Regress', 'TestSubObj'))
      prop = builder.find_property("int")
      assert_equal "int", prop.name
    end

    it "raises an error if the property is not found" do
      builder = GirFFI::Builders::ObjectBuilder.new(
        get_introspection_data('Regress', 'TestSubObj'))
      assert_raises RuntimeError do
        builder.find_property("this-property-does-not-exist")
      end
    end
  end

  describe "#function_definition" do
    before do
      @cbuilder = GirFFI::Builders::ObjectBuilder.new get_introspection_data('Regress', 'TestObj')
      @go = get_method_introspection_data 'Regress', 'TestObj', 'instance_method'
    end

    it "delegates definition to FunctionBuilder" do
      code = @cbuilder.send :function_definition, @go
      expected = GirFFI::Builders::FunctionBuilder.new(@go).generate
      assert_equal cws(expected), cws(code)
    end
  end

  describe "#object_class" do
    it "returns an object of the class struct type" do
      obj_builder.object_class.must_be_instance_of Regress::TestObjClass
    end
  end
end
