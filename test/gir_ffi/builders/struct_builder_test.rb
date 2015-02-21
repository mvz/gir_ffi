require 'gir_ffi_test_helper'

describe GirFFI::Builders::StructBuilder do
  describe '#layout_specification' do
    it 'returns the correct layout for Regress::TestStructA' do
      info = get_introspection_data 'Regress', 'TestStructA'
      builder = GirFFI::Builders::StructBuilder.new info
      builder.layout_specification.must_equal [:some_int, :int32, 0,
                                               :some_int8, :int8, 4,
                                               :some_double, :double, 8,
                                               :some_enum, Regress::TestEnum, 16]
    end
  end

  describe 'for a struct with a simple layout' do
    before do
      @field = Object.new

      @struct = Object.new
      stub(@struct).namespace { 'Foo' }
      stub(@struct).safe_name { 'Bar' }
      stub(@struct).fields { [@field] }

      @builder = GirFFI::Builders::StructBuilder.new @struct
    end

    it 'creates the correct layout specification' do
      expect(@field).to receive(:layout_specification).and_return [:bar, :int32, 0]
      spec = @builder.send :layout_specification
      assert_equal [:bar, :int32, 0], spec
    end
  end

  describe 'for a struct with a layout with a complex type' do
    it 'does not flatten the complex type specification' do
      expect(simplefield = Object.new).to receive(:layout_specification).and_return [:bar, :foo, 0]
      expect(complexfield = Object.new).to receive(:layout_specification).and_return [:baz, [:qux, 2], 0]
      expect(struct = Object.new).to receive(:fields).and_return [simplefield, complexfield]

      stub(struct).safe_name { 'Bar' }
      stub(struct).namespace { 'Foo' }

      builder = GirFFI::Builders::StructBuilder.new struct
      spec = builder.send :layout_specification
      assert_equal [:bar, :foo, 0, :baz, [:qux, 2], 0], spec
    end
  end

  describe 'for a struct without defined fields' do
    it 'uses a single field of the parent struct type as the default layout' do
      @gir = GObjectIntrospection::IRepository.default
      @gir.require 'GObject', nil

      stub(info = Object.new).parent { @gir.find_by_name 'GObject', 'Object' }
      stub(info).fields { [] }
      stub(info).info_type { :object }
      stub(info).safe_name { 'Bar' }
      stub(info).namespace { 'Foo' }

      @classbuilder = GirFFI::Builders::ObjectBuilder.new info

      spec = @classbuilder.send :layout_specification
      assert_equal [:parent, GObject::Object::Struct, 0], spec
    end
  end
end
