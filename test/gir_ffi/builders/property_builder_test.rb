require 'gir_ffi_test_helper'

describe GirFFI::Builders::PropertyBuilder do
  let(:builder) { GirFFI::Builders::PropertyBuilder.new property_info }

  describe 'for a property of type :glist' do
    let(:property_info) { get_property_introspection_data('Regress', 'TestObj', 'list') }
    it 'generates the correct getter definition' do
      expected = <<-CODE.reset_indentation
      def list
        _v1 = get_property("list").get_value_plain
        _v2 = GLib::List.wrap(:utf8, _v1)
        _v2
      end
      CODE

      builder.getter_def.must_equal expected
    end

    it 'generates the correct setter definition' do
      expected = <<-CODE.reset_indentation
      def list= value
        _v1 = GLib::List.from(:utf8, value)
        set_property("list", _v1)
      end
      CODE

      builder.setter_def.must_equal expected
    end
  end

  describe 'for a property of type :ghash' do
    let(:property_info) { get_property_introspection_data('Regress', 'TestObj', 'hash-table') }
    it 'generates the correct getter definition' do
      expected = <<-CODE.reset_indentation
      def hash_table
        _v1 = get_property("hash-table").get_value_plain
        _v2 = GLib::HashTable.wrap([:utf8, :gint8], _v1)
        _v2
      end
      CODE

      builder.getter_def.must_equal expected
    end

    it 'generates the correct setter definition' do
      expected = <<-CODE.reset_indentation
      def hash_table= value
        _v1 = GLib::HashTable.from([:utf8, :gint8], value)
        set_property("hash-table", _v1)
      end
      CODE

      builder.setter_def.must_equal expected
    end
  end

  describe 'for a property of type :strv' do
    let(:property_info) {
      get_property_introspection_data('GIMarshallingTests',
                                      'PropertiesObject',
                                      'some-strv')
    }
    before do
      skip unless property_info
    end

    it 'generates the correct getter definition' do
      expected = <<-CODE.reset_indentation
      def some_strv
        get_property("some-strv").get_value
      end
      CODE

      builder.getter_def.must_equal expected
    end

    it 'generates the correct setter definition' do
      expected = <<-CODE.reset_indentation
      def some_strv= value
        _v1 = GLib::Strv.from(value)
        set_property("some-strv", _v1)
      end
      CODE

      builder.setter_def.must_equal expected
    end
  end

  describe 'for a property of type :utf8' do
    let(:property_info) { get_property_introspection_data('Regress', 'TestObj', 'string') }
    it 'generates the correct getter definition' do
      expected = <<-CODE.reset_indentation
      def string
        get_property("string").get_value
      end
      CODE

      builder.getter_def.must_equal expected
    end

    it 'generates the correct setter definition' do
      expected = <<-CODE.reset_indentation
      def string= value
        set_property("string", value)
      end
      CODE

      builder.setter_def.must_equal expected
    end
  end

  describe '#container_defines_getter_method?' do
    let(:property_info) { Object.new.tap { |o| o.extend GirFFI::InfoExt::IPropertyInfo } }
    let(:container_info) { Object.new }

    before do
      stub(property_info).container { container_info }
      stub(property_info).name { 'foo-bar' }
      stub(container_info).find_instance_method('foo_bar') { true }
    end

    it 'finds methods with underscores for properties with dashes' do
      builder.container_defines_getter_method?.must_equal true
    end
  end
end
