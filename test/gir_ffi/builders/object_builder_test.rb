require 'gir_ffi_test_helper'

describe GirFFI::Builders::ObjectBuilder do
  let(:obj_builder) do
    GirFFI::Builders::ObjectBuilder.new(
      get_introspection_data('Regress', 'TestObj'))
  end
  let(:sub_obj_builder) do
    GirFFI::Builders::ObjectBuilder.new(
      get_introspection_data('Regress', 'TestSubObj'))
  end

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

  describe '#find_property' do
    it 'finds a property specified on the class itself' do
      prop = obj_builder.find_property('int')
      prop.name.must_equal 'int'
    end

    it 'finds a property specified on the parent class' do
      prop = sub_obj_builder.find_property('int')
      prop.name.must_equal 'int'
    end

    it 'raises an error if the property is not found' do
      proc do
        sub_obj_builder.find_property('this-property-does-not-exist')
      end.must_raise RuntimeError
    end
  end

  describe '#object_class_struct' do
    it 'returns the class struct type' do
      obj_builder.object_class_struct.must_equal Regress::TestObjClass
    end
  end
end
