# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::Builders::FieldBuilder do
  let(:target_class) { 'dummy' }
  let(:instance) { GirFFI::Builders::FieldBuilder.new field_info, target_class }

  describe 'for a field of type :gint8 with an offset' do
    let(:field_info) { get_field_introspection_data 'Regress', 'TestSimpleBoxedA', 'some_int8' }
    it 'creates the right getter method' do
      expected = <<-CODE.reset_indentation
        def some_int8
          _v1 = @struct.to_ptr
          _v2 = _v1.get_int8(#{field_info.offset})
          _v2
        end
      CODE
      _(instance.getter_def).must_equal expected
    end

    it 'creates the right setter method' do
      expected = <<-CODE.reset_indentation
        def some_int8= value
          _v1 = @struct.to_ptr
          _v2 = value
          _v1.put_int8 #{field_info.offset}, _v2
        end
      CODE
      _(instance.setter_def).must_equal expected
    end
  end

  describe 'for a field of type :struct' do
    let(:field_info) { get_field_introspection_data 'Regress', 'TestBoxed', 'nested_a' }
    it 'creates the right getter method' do
      expected = <<-CODE.reset_indentation
        def nested_a
          _v1 = @struct.to_ptr
          _v2 = Regress::TestSimpleBoxedA.get_value_from_pointer(_v1, #{field_info.offset})
          _v3 = Regress::TestSimpleBoxedA.wrap(_v2)
          _v3
        end
      CODE
      _(instance.getter_def).must_equal expected
    end

    it 'creates the right setter method' do
      expected = <<-CODE.reset_indentation
        def nested_a= value
          _v1 = @struct.to_ptr
          _v2 = Regress::TestSimpleBoxedA.copy_from(value)
          Regress::TestSimpleBoxedA.copy_value_to_pointer(_v2, _v1, #{field_info.offset})
        end
      CODE
      _(instance.setter_def).must_equal expected
    end
  end

  describe 'for a field of type :enum' do
    let(:field_info) { get_field_introspection_data 'Regress', 'TestStructA', 'some_enum' }
    it 'creates the right getter method' do
      expected = <<-CODE.reset_indentation
        def some_enum
          _v1 = @struct.to_ptr
          _v2 = Regress::TestEnum.get_value_from_pointer(_v1, #{field_info.offset})
          _v2
        end
      CODE
      _(instance.getter_def).must_equal expected
    end
  end

  describe 'for an inline fixed-size array field' do
    let(:field_info) { get_field_introspection_data 'Regress', 'TestStructE', 'some_union' }
    it 'creates the right getter method' do
      expected = <<-CODE.reset_indentation
        def some_union
          _v1 = @struct.to_ptr
          _v2 = GirFFI::SizedArray.get_value_from_pointer(_v1, #{field_info.offset})
          _v3 = GirFFI::SizedArray.wrap(Regress::TestStructE__some_union__union, 2, _v2)
          _v3
        end
      CODE
      _(instance.getter_def).must_equal expected
    end

    it 'creates the right setter method' do
      expected = <<-CODE.reset_indentation
        def some_union= value
          _v1 = @struct.to_ptr
          GirFFI::ArgHelper.check_fixed_array_size 2, value, \"value\"
          _v2 = GirFFI::SizedArray.copy_from(Regress::TestStructE__some_union__union, 2, value)
          GirFFI::SizedArray.copy_value_to_pointer(_v2, _v1, #{field_info.offset})
        end
      CODE
      _(instance.setter_def).must_equal expected
    end
  end

  describe 'for a field of type :callback' do
    let(:field_info) { get_field_introspection_data 'GObject', 'TypeInfo', 'class_init' }
    it 'creates the right setter method' do
      expected = <<-CODE.reset_indentation
        def class_init= value
          _v1 = @struct.to_ptr
          _v2 = GObject::ClassInitFunc.from(value)
          GObject::ClassInitFunc.copy_value_to_pointer(_v2, _v1, #{field_info.offset})
        end
      CODE
      _(instance.setter_def).must_equal expected
    end
  end

  describe 'for a field with a related array length field' do
    let(:field_info) { get_field_introspection_data 'GObject', 'SignalQuery', 'param_types' }
    let(:n_params_field_info) { get_field_introspection_data 'GObject', 'SignalQuery', 'n_params' }

    it 'creates the right getter method' do
      skip if field_info.field_type.array_length < 0
      expected = <<-CODE.reset_indentation
        def param_types
          _v1 = @struct.to_ptr
          _v2 = _v1.get_uint32(#{n_params_field_info.offset})
          _v3 = @struct.to_ptr
          _v4 = _v3.get_pointer(#{field_info.offset})
          _v5 = GirFFI::SizedArray.wrap(:GType, _v2, _v4)
          _v5
        end
      CODE
      _(instance.getter_def).must_equal expected
    end
  end
end
