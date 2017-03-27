# frozen_string_literal: true

require 'gir_ffi_test_helper'

describe GirFFI::Builders::ReturnValueBuilder do
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:type_info) { method_info.return_type }
  let(:ownership_transfer) { method_info.caller_owns }
  let(:return_type_info) { GirFFI::ReturnValueInfo.new(type_info, ownership_transfer, false) }
  let(:builder) do
    GirFFI::Builders::ReturnValueBuilder.new(var_gen, return_type_info)
  end

  describe 'for :gint32' do
    let(:method_info) do
      get_introspection_data('GIMarshallingTests',
                             'int_return_min')
    end

    it 'has no statements in #post_conversion' do
      builder.post_conversion.must_equal []
    end

    it 'returns the result of the c function directly' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v1'
    end
  end

  describe 'for :struct' do
    describe 'with transfer :nothing' do
      let(:method_info) do
        get_method_introspection_data('GIMarshallingTests',
                                      'BoxedStruct',
                                      'returnv')
      end

      it 'wraps and copies the result in #post_conversion' do
        builder.capture_variable_name.must_equal '_v1'
        builder.post_conversion.must_equal ['_v2 = GIMarshallingTests::BoxedStruct.wrap_copy(_v1)']
      end

      it 'returns the copied result' do
        builder.capture_variable_name.must_equal '_v1'
        builder.return_value_name.must_equal '_v2'
      end
    end
  end

  describe 'for :union' do
    let(:method_info) do
      get_method_introspection_data('GIMarshallingTests',
                                    'Union',
                                    'returnv')
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GIMarshallingTests::Union.wrap_copy(_v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :interface' do
    let(:method_info) do
      get_method_introspection_data('Gio',
                                    'File',
                                    'new_for_commandline_arg')
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = Gio::File.wrap(_v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :object' do
    describe 'with full ownership transfer' do
      let(:method_info) do
        get_method_introspection_data('GIMarshallingTests',
                                      'Object',
                                      'full_return')
      end

      it 'wraps the result in #post_conversion' do
        builder.capture_variable_name.must_equal '_v1'
        builder.post_conversion.must_equal ['_v2 = GIMarshallingTests::Object.wrap(_v1)']
      end

      it 'returns the wrapped result' do
        builder.capture_variable_name.must_equal '_v1'
        builder.return_value_name.must_equal '_v2'
      end
    end

    describe 'with no ownership transfer' do
      let(:method_info) do
        get_method_introspection_data('GIMarshallingTests',
                                      'Object',
                                      'none_return')
      end

      it 'wraps the result in #post_conversion' do
        builder.capture_variable_name.must_equal '_v1'
        builder.post_conversion.
          must_equal ['_v2 = GIMarshallingTests::Object.wrap(_v1).tap { |it| it && it.ref }']
      end

      it 'returns the wrapped result' do
        builder.capture_variable_name.must_equal '_v1'
        builder.return_value_name.must_equal '_v2'
      end
    end
  end

  describe 'for :strv' do
    let(:method_info) do
      get_method_introspection_data('GLib',
                                    'KeyFile',
                                    'get_locale_string_list')
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GLib::Strv.wrap(_v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :zero_terminated' do
    let(:method_info) do
      get_method_introspection_data('GLib',
                                    'Variant',
                                    'dup_bytestring')
    end
    before do
      skip unless type_info.zero_terminated?
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GirFFI::ZeroTerminated.wrap(:guint8, _v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :byte_array' do
    let(:method_info) do
      get_introspection_data('GIMarshallingTests',
                             'bytearray_full_return')
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GLib::ByteArray.wrap(_v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :ptr_array' do
    let(:method_info) do
      get_introspection_data('GIMarshallingTests',
                             'gptrarray_utf8_none_return')
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GLib::PtrArray.wrap(:utf8, _v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :glist' do
    let(:method_info) do
      get_introspection_data('GIMarshallingTests',
                             'glist_int_none_return')
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GLib::List.wrap(:gint32, _v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :gslist' do
    let(:method_info) do
      get_introspection_data('GIMarshallingTests',
                             'gslist_int_none_return')
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GLib::SList.wrap(:gint32, _v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :ghash' do
    let(:method_info) do
      get_introspection_data('GIMarshallingTests',
                             'ghashtable_int_none_return')
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GLib::HashTable.wrap([:gint32, :gint32], _v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :array' do
    let(:method_info) do
      get_introspection_data('GIMarshallingTests',
                             'garray_int_none_return')
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GLib::Array.wrap(:gint32, _v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :error' do
    let(:method_info) do
      get_introspection_data('GIMarshallingTests',
                             'gerror_return')
    end

    it 'wraps the result in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GLib::Error.wrap(_v1)']
    end

    it 'returns the wrapped result' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for :c' do
    describe 'with fixed size' do
      let(:method_info) do
        get_introspection_data('GIMarshallingTests',
                               'array_fixed_int_return')
      end

      it 'converts the result in #post_conversion' do
        builder.capture_variable_name.must_equal '_v1'
        builder.post_conversion.must_equal ['_v2 = GirFFI::SizedArray.wrap(:gint32, 4, _v1)']
      end

      it 'returns the wrapped result' do
        builder.capture_variable_name.must_equal '_v1'
        builder.return_value_name.must_equal '_v2'
      end
    end

    describe 'with separate size parameter' do
      let(:length_argument) { Object.new }
      let(:method_info) do
        get_method_introspection_data('GIMarshallingTests',
                                      'Object',
                                      'method_array_return')
      end

      before do
        allow(length_argument).to receive(:post_converted_name).and_return 'bar'
        builder.length_arg = length_argument
      end

      it 'converts the result in #post_conversion' do
        builder.capture_variable_name.must_equal '_v1'
        builder.post_conversion.must_equal ['_v2 = GirFFI::SizedArray.wrap(:gint32, bar, _v1)']
      end

      it 'returns the wrapped result' do
        builder.capture_variable_name.must_equal '_v1'
        builder.return_value_name.must_equal '_v2'
      end
    end
  end

  describe 'for :utf8' do
    describe 'with no transfer' do
      let(:method_info) do
        get_introspection_data('GIMarshallingTests', 'utf8_none_return')
      end

      it 'converts the result in #post_conversion' do
        builder.capture_variable_name.must_equal '_v1'
        builder.post_conversion.must_equal ['_v2 = _v1.to_utf8']
      end

      it 'returns the converted result' do
        builder.capture_variable_name.must_equal '_v1'
        builder.return_value_name.must_equal '_v2'
      end
    end

    describe 'with full transfer' do
      let(:method_info) do
        get_introspection_data('GIMarshallingTests', 'utf8_full_return')
      end

      it 'autoreleases and converts the result in #post_conversion' do
        builder.capture_variable_name.must_equal '_v1'
        builder.post_conversion.
          must_equal ['_v2 = GirFFI::AllocationHelper.free_after _v1, &:to_utf8']
      end

      it 'returns the converted result' do
        builder.capture_variable_name.must_equal '_v1'
        builder.return_value_name.must_equal '_v2'
      end
    end
  end

  describe 'for :void pointer' do
    let(:ownership_transfer) { :nothing }
    let(:callback_info) do
      get_introspection_data('GIMarshallingTests', 'CallbackIntInt')
    end
    let(:type_info) { callback_info.args[1].argument_type }

    before do
      skip unless callback_info
    end

    it 'has no statements in #post_conversion' do
      builder.post_conversion.must_equal []
    end

    it 'returns the result of the c function directly' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v1'
    end
  end

  describe 'for :void' do
    let(:method_info) do
      get_method_introspection_data('Regress', 'TestObj', 'null_out')
    end

    it 'has no statements in #post_conversion' do
      builder.post_conversion.must_equal []
    end

    it 'marks itself as irrelevant' do
      builder.relevant?.must_equal false
    end

    it 'returns nothing' do
      builder.return_value_name.must_be_nil
    end
  end

  describe 'for a closure argument' do
    let(:ownership_transfer) { :nothing }
    let(:callback_info) do
      get_introspection_data('Regress', 'TestCallbackUserData')
    end
    let(:type_info) { callback_info.args[0].argument_type }

    before do
      builder.closure = true
    end

    it 'fetches the stored object in #post_conversion' do
      builder.capture_variable_name.must_equal '_v1'
      builder.post_conversion.must_equal ['_v2 = GirFFI::ArgHelper::OBJECT_STORE.fetch(_v1)']
    end

    it 'returns the stored object' do
      builder.capture_variable_name.must_equal '_v1'
      builder.return_value_name.must_equal '_v2'
    end
  end

  describe 'for a skipped return value' do
    let(:method_info) do
      get_method_introspection_data('Regress', 'TestObj', 'skip_return_val')
    end
    let(:return_type_info) { GirFFI::ReturnValueInfo.new(type_info, :nothing, true) }

    it 'has no statements in #post_conversion' do
      builder.post_conversion.must_equal []
    end

    it 'marks itself as irrelevant' do
      builder.relevant?.must_equal false
    end

    it 'returns nothing' do
      builder.return_value_name.must_be_nil
    end
  end
end
