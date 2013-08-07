require 'gir_ffi/base_argument_builder'

module GirFFI
  # Implements building post-processing statements for return values.
  class ReturnValueBuilder < BaseArgumentBuilder
    def initialize var_gen, type_info, is_constructor
      super var_gen, nil, type_info, :return
      @is_constructor = is_constructor
    end

    def post
      if has_conversion?
        [ "#{retname} = #{post_conversion}" ]
      else
        []
      end
    end

    def inarg
      nil
    end

    # TODO: Rename
    def cvar
      callarg unless is_void_return_value?
    end

    def retval
      if has_conversion?
        super
      elsif is_void_return_value?
        nil
      else
        callarg
      end
    end

    private

    def post_conversion
      if needs_constructor_wrap?
        "self.constructor_wrap(#{cvar})"
      else
        case specialized_type_tag
        when :utf8
          # TODO: Re-use methods in InOutPointer for this conversion
          "GirFFI::ArgHelper.ptr_to_utf8(#{cvar})"
        when :c
          "GLib::SizedArray.wrap(#{subtype_tag_or_class_name}, #{array_size}, #{cvar})"
        else
          "#{argument_class_name}.wrap(#{conversion_arguments cvar})"
        end
      end
    end

    def retname
      @retname ||= @var_gen.new_var
    end

    def has_conversion?
      needs_wrapping? || [ :utf8, :c ].include?(specialized_type_tag)
    end

    # TODO: Merge with ArgumentBuilder#needs_outgoing_parameter_conversion?
    def needs_wrapping?
      [ :array, :byte_array, :error, :ghash, :glist, :gslist, :interface,
        :object, :ptr_array, :struct, :strv, :union, :zero_terminated
      ].include?(specialized_type_tag)
    end

    def needs_constructor_wrap?
      @is_constructor && [ :interface, :object ].include?(specialized_type_tag)
    end

    def is_void_return_value?
      specialized_type_tag == :void && !type_info.pointer?
    end
  end
end
