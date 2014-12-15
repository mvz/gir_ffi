require 'gir_ffi_test_helper'

describe GirFFI::Builders::ArgumentBuilder do
  let(:var_gen) { GirFFI::VariableNameGenerator.new }
  let(:builder) { GirFFI::Builders::ArgumentBuilder.new(var_gen, arg_info) }

  describe 'for an argument with direction :in' do
    describe 'for :callback' do
      let(:arg_info) {
        get_introspection_data('Regress', 'test_callback_destroy_notify').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = Regress::TestCallbackUserData.from(callback)']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal []
      end
    end

    describe 'for :zero_terminated' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests',
                               'array_in_len_zero_terminated').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::ZeroTerminated.from(:gint32, ints)']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal []
      end
    end

    describe 'for :void' do
      let(:arg_info) { get_introspection_data('Regress', 'test_callback_user_data').args[1] }

      describe 'when it is a regular argument' do
        before do
          builder.closure = false
        end

        it 'has the correct value for #pre_conversion' do
          builder.pre_conversion.must_equal ['_v1 = GirFFI::InPointer.from(:void, user_data)']
        end

        it 'has the correct value for #post_conversion' do
          builder.post_conversion.must_equal []
        end
      end

      describe 'when it is a closure' do
        before do
          builder.closure = true
        end

        it 'has the correct value for #pre_conversion' do
          builder.pre_conversion.must_equal ['_v1 = GirFFI::InPointer.from_closure_data(user_data)']
        end

        it 'has the correct value for #post_conversion' do
          builder.post_conversion.must_equal []
        end
      end
    end
  end

  describe 'for an argument with direction :out' do
    describe 'for :enum' do
      let(:arg_info) { get_introspection_data('GIMarshallingTests', 'genum_out').args[0] }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for GIMarshallingTests::GEnum']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = _v1.to_value']
      end
    end

    describe 'for :flags' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'flags_out').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for GIMarshallingTests::Flags']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = _v1.to_value']
      end
    end

    describe 'for :object' do
      let(:arg_info) {
        get_method_introspection_data('Regress', 'TestObj', 'null_out').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, Regress::TestObj]']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = Regress::TestObj.wrap(_v1.to_value)']
      end
    end

    describe 'for :struct' do

      describe 'when not allocated by the caller' do
        let(:arg_info) {
          get_introspection_data('GIMarshallingTests', 'boxed_struct_out').args[0]
        }

        it 'has the correct value for #pre_conversion' do
          builder.pre_conversion.must_equal [
            '_v1 = GirFFI::InOutPointer.for [:pointer, GIMarshallingTests::BoxedStruct]'
          ]
        end

        it 'has the correct value for #post_conversion' do
          builder.post_conversion.must_equal ['_v2 = GIMarshallingTests::BoxedStruct.wrap(_v1.to_value)']
        end
      end

      describe 'when allocated by the caller' do
        let(:arg_info) {
          get_method_introspection_data('Regress', 'TestStructA', 'clone').args[0]
        }

        it 'has the correct value for #pre_conversion' do
          builder.pre_conversion.must_equal ['_v1 = Regress::TestStructA.new']
        end

        it 'has empty #post_conversion' do
          builder.post_conversion.must_equal []
        end
      end
    end

    describe 'for :strv' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'gstrv_out').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, :strv]']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = GLib::Strv.wrap(_v1.to_value)']
      end
    end

    describe 'for :array' do

      describe 'when allocated by the callee' do
        let(:arg_info) {
          get_introspection_data('GIMarshallingTests', 'garray_utf8_none_out').args[0]
        }

        it 'has the correct value for #pre_conversion' do
          builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, :array]']
        end

        it 'has the correct value for #post_conversion' do
          builder.post_conversion.must_equal ['_v2 = GLib::Array.wrap(:utf8, _v1.to_value)']
        end
      end

      describe 'when allocated by the caller' do
        let(:function_info) {
          get_introspection_data('GIMarshallingTests', 'garray_utf8_full_out_caller_allocated')
        }

        let(:arg_info) { function_info.args[0] }

        before do
          skip unless function_info
        end

        it 'has the correct value for #pre_conversion' do
          builder.pre_conversion.must_equal ['_v1 = GLib::Array.new :utf8']
        end

        it 'has empty #post_conversion' do
          builder.post_conversion.must_equal []
        end
      end
    end

    describe 'for :ptr_array' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'gptrarray_utf8_none_out').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, :ptr_array]']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = GLib::PtrArray.wrap(:utf8, _v1.to_value)']
      end
    end

    describe 'for :error' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'gerror_out').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, :error]']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = GLib::Error.wrap(_v1.to_value)']
      end
    end

    describe 'for :c' do

      describe 'with fixed size' do
        let(:arg_info) {
          get_introspection_data('GIMarshallingTests', 'array_fixed_out').args[0]
        }

        it 'has the correct value for #pre_conversion' do
          builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, :c]']
        end

        it 'has the correct value for #post_conversion' do
          builder.post_conversion.must_equal ['_v2 = GirFFI::SizedArray.wrap(:gint32, 4, _v1.to_value)']
        end
      end

      describe 'with separate size parameter' do
        let(:arg_info) {
          get_introspection_data('GIMarshallingTests', 'array_out').args[0]
        }

        let(:length_argument) { Object.new }
        before do
          stub(length_argument).post_converted_name { 'bar' }
          builder.length_arg = length_argument
        end

        it 'has the correct value for #pre_conversion' do
          builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, :c]']
        end

        it 'has the correct value for #post_conversion' do
          builder.post_conversion.must_equal ['_v2 = GirFFI::SizedArray.wrap(:gint32, bar, _v1.to_value)']
        end
      end
    end

    describe 'for :glist' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'glist_utf8_none_out').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, :glist]']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = GLib::List.wrap(:utf8, _v1.to_value)']
      end
    end

    describe 'for :gslist' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'gslist_utf8_none_out').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, :gslist]']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = GLib::SList.wrap(:utf8, _v1.to_value)']
      end
    end

    describe 'for :ghash' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'ghashtable_utf8_none_out').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, [:ghash, :utf8, :utf8]]']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = GLib::HashTable.wrap([:utf8, :utf8], _v1.to_value)']
      end
    end
  end

  describe 'for an argument with direction :inout' do
    describe 'for :enum' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'enum_inout').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for GIMarshallingTests::Enum',
                                           "_v1.set_value #{arg_info.name}"]
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = _v1.to_value']
      end
    end

    describe 'for :flags' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'no_type_flags_inout').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for GIMarshallingTests::NoTypeFlags',
                                           "_v1.set_value #{arg_info.name}"]
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = _v1.to_value']
      end
    end

    describe 'for :gint32' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'int32_inout_min_max').args[0]
      }

      it 'has the correct value for method_argument_name' do
        builder.method_argument_name.must_equal "#{arg_info.name}"
      end

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for :gint32',
                                           "_v1.set_value #{arg_info.name}"]
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = _v1.to_value']
      end
    end

    describe 'for an array length' do
      let(:function_info) {
        get_introspection_data('Regress', 'test_array_int_inout')
      }
      let(:arg_info) { function_info.args[0] }
      let(:array_arg_info) { function_info.args[1] }
      let(:array_arg_builder) {
        GirFFI::Builders::ArgumentBuilder.new(var_gen, array_arg_info)
      }

      before do
        builder.array_arg = array_arg_builder
      end

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['n_ints = ints.nil? ? 0 : ints.length',
                                           '_v1 = GirFFI::InOutPointer.for :gint32',
                                           '_v1.set_value n_ints']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = _v1.to_value']
      end
    end

    describe 'for :strv' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'gstrv_inout').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, :strv]',
                                           '_v1.set_value GLib::Strv.from(g_strv)']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = GLib::Strv.wrap(_v1.to_value)']
      end
    end

    describe 'for :ptr_array' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'gptrarray_utf8_none_inout').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for [:pointer, :ptr_array]',
                                           '_v1.set_value GLib::PtrArray.from(:utf8, parray_)']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = GLib::PtrArray.wrap(:utf8, _v1.to_value)']
      end
    end

    describe 'for :utf8' do
      let(:arg_info) {
        get_introspection_data('GIMarshallingTests', 'utf8_none_inout').args[0]
      }

      it 'has the correct value for #pre_conversion' do
        builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for :utf8',
                                           '_v1.set_value GirFFI::InPointer.from(:utf8, utf8)']
      end

      it 'has the correct value for #post_conversion' do
        builder.post_conversion.must_equal ['_v2 = _v1.to_value.to_utf8']
      end
    end

    describe 'for :c' do
      describe 'with fixed size' do
        let(:arg_info) {
          get_introspection_data('GIMarshallingTests', 'array_fixed_inout').args[0]
        }

        it 'has the correct value for #pre_conversion' do
          builder.pre_conversion.must_equal [
            "GirFFI::ArgHelper.check_fixed_array_size 4, ints, \"ints\"",
            '_v1 = GirFFI::InOutPointer.for [:pointer, :c]',
            '_v1.set_value GirFFI::SizedArray.from(:gint32, 4, ints)'
          ]
        end

        it 'has the correct value for #post_conversion' do
          builder.post_conversion.must_equal ['_v2 = GirFFI::SizedArray.wrap(:gint32, 4, _v1.to_value)']
        end
      end

      describe 'with separate size parameter' do
        let(:function_info) {
          get_introspection_data('Regress', 'test_array_int_inout')
        }
        let(:length_arg_info) { function_info.args[0] }
        let(:arg_info) { function_info.args[1] }
        let(:length_arg_builder) {
          GirFFI::Builders::ArgumentBuilder.new(var_gen, length_arg_info)
        }

        before do
          builder.length_arg = length_arg_builder
        end

        it 'has the correct value for #pre_conversion' do
          builder.pre_conversion.must_equal [
            '_v1 = GirFFI::InOutPointer.for [:pointer, :c]',
            '_v1.set_value GirFFI::SizedArray.from(:gint32, -1, ints)'
          ]
        end

        it 'has the correct value for #post_conversion' do
          builder.post_conversion.must_equal ['_v3 = GirFFI::SizedArray.wrap(:gint32, _v2, _v1.to_value)']
        end
      end
    end
  end

  describe 'for a skipped argument with direction :in' do
    let(:arg_info) {
      get_method_introspection_data('Regress', 'TestObj', 'skip_param').args[2]
    }

    it 'has the correct value for method_argument_name' do
      builder.method_argument_name.must_be_nil
    end

    it 'has the correct value for #pre_conversion' do
      builder.pre_conversion.must_equal ['_v1 = 0']
    end

    it 'has the correct value for #post_conversion' do
      builder.post_conversion.must_equal []
    end
  end

  describe 'for a skipped argument with direction :inout' do
    let(:arg_info) {
      get_method_introspection_data('Regress', 'TestObj', 'skip_inout_param').args[3]
    }

    it 'has the correct value for method_argument_name' do
      builder.method_argument_name.must_be_nil
    end

    it 'has the correct value for #pre_conversion' do
      builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for :gint32',
                                         '_v1.set_value 0']
    end

    it 'has the correct value for #post_conversion' do
      builder.post_conversion.must_equal []
    end
  end

  describe 'for a skipped argument with direction :out' do
    let(:arg_info) {
      get_method_introspection_data('Regress', 'TestObj', 'skip_out_param').args[1]
    }

    it 'has the correct value for method_argument_name' do
      builder.method_argument_name.must_be_nil
    end

    it 'has the correct value for #pre_conversion' do
      builder.pre_conversion.must_equal ['_v1 = GirFFI::InOutPointer.for :gint32']
    end

    it 'has the correct value for #post_conversion' do
      builder.post_conversion.must_equal []
    end
  end
end
