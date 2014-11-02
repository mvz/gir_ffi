require 'gir_ffi_test_helper'

describe GirFFI::Builders::ObjectBuilder do
  let(:obj_builder) {
    GirFFI::Builders::ObjectBuilder.new(
    get_introspection_data('Regress', 'TestObj'))
  }
  let(:sub_obj_builder) {
    GirFFI::Builders::ObjectBuilder.new(
    get_introspection_data('Regress', 'TestSubObj'))
  }

  describe '#find_signal' do
    it 'finds the signal "test" for TestObj' do
      sig = obj_builder.find_signal 'test'
      sig.name.must_equal 'test'
    end

    it 'finds the signal "test" for TestSubObj' do
      sig = sub_obj_builder.find_signal 'test'
      sig.name.must_equal 'test'
    end

    it 'finds the signal "changed" for Gtk::Entry' do
      builder = GirFFI::Builders::ObjectBuilder.new get_introspection_data('Gtk', 'Entry')
      sig = builder.find_signal 'changed'
      sig.name.must_equal 'changed'
    end

    it "raises an error for a signal that doesn't exist" do
      msg = nil
      begin
        obj_builder.find_signal 'foo'
      rescue RuntimeError => e
        msg = e.message
      end
      assert_match(/^Signal/, msg)
    end
  end

  describe "#find_property" do
    it "finds a property specified on the class itself" do
      prop = obj_builder.find_property("int")
      prop.name.must_equal "int"
    end

    it "finds a property specified on the parent class" do
      prop = sub_obj_builder.find_property("int")
      prop.name.must_equal "int"
    end

    it "raises an error if the property is not found" do
      proc {
        sub_obj_builder.find_property("this-property-does-not-exist")
      }.must_raise RuntimeError
    end
  end

  describe "#function_definition" do
    let(:method_info) {
      get_method_introspection_data 'Regress', 'TestObj', 'instance_method'
    }

    it "delegates definition to FunctionBuilder" do
      code = obj_builder.send :function_definition, method_info
      expected = GirFFI::Builders::FunctionBuilder.new(method_info).generate
      code.must_equal expected
    end
  end

  describe "#object_class_struct" do
    it "returns the class struct type" do
      obj_builder.object_class_struct.must_equal Regress::TestObjClass
    end
  end
end
