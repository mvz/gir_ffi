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
  let(:param_spec_builder) do
    GirFFI::Builders::ObjectBuilder.new(
      get_introspection_data('GObject', 'ParamSpec'))
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

    it "returns nil for a signal that doesn't exist" do
      obj_builder.find_signal('foo').must_be_nil
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

    it 'returns nil if the property is not found' do
      sub_obj_builder.find_property('this-property-does-not-exist').must_be_nil
    end
  end

  describe '#object_class_struct' do
    it 'returns the class struct type' do
      obj_builder.object_class_struct.must_equal Regress::TestObjClass
    end

    it 'returns the parent struct type for classes without their own struct' do
      binding_info = get_introspection_data 'GObject', 'Binding'
      builder = GirFFI::Builders::ObjectBuilder.new binding_info
      builder.object_class_struct.must_equal GObject::ObjectClass
    end
  end

  # TODO: Improve this spec to use less mocking
  describe 'for a struct without defined fields' do
    it 'uses a single field of the parent struct type as the default layout' do
      @gir = GObjectIntrospection::IRepository.default
      @gir.require 'GObject', nil

      allow(info = Object.new).to receive(:parent).and_return @gir.find_by_name 'GObject', 'Object'
      allow(info).to receive(:fields).and_return []
      allow(info).to receive(:info_type).and_return :object
      allow(info).to receive(:safe_name).and_return 'Bar'
      allow(info).to receive(:namespace).and_return 'Foo'

      @classbuilder = GirFFI::Builders::ObjectBuilder.new info

      spec = @classbuilder.send :layout_specification
      assert_equal [:parent, GObject::Object::Struct, 0], spec
    end
  end

  describe '#eligible_fields' do
    it 'skips fields that have a matching getter method' do
      result = param_spec_builder.eligible_fields
      result.map(&:name).wont_include 'name'
    end

    it 'skips fields that have a matching property' do
      result = obj_builder.eligible_fields
      result.map(&:name).wont_include 'hash_table'
    end

    it 'skips the parent instance field' do
      result = obj_builder.eligible_fields
      result.map(&:name).wont_include 'parent_instance'
    end
  end
end
