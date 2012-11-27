require 'gir_ffi/base_argument_builder'

module GirFFI
  # Implements building post-processing statements for return values.
  class ReturnValueBuilder < BaseArgumentBuilder
    def initialize var_gen, type_info, is_constructor
      super var_gen, nil, type_info, :return
      @is_constructor = is_constructor
    end

    def post
      if needs_wrapping?
        if specialized_type_tag == :zero_terminated
          # FIXME: This is almost certainly wrong.
          [ "#{retname} = #{argument_class_name}.wrap(#{cvar})" ]
        elsif [ :interface, :object ].include?(specialized_type_tag) && @is_constructor
          [ "#{retname} = self.constructor_wrap(#{cvar})" ]
        else
          [ "#{retname} = #{argument_class_name}.wrap(#{return_value_conversion_arguments})" ]
        end
      elsif specialized_type_tag == :utf8
        # TODO: Re-use methods in InOutPointer for this conversion
        [ "#{retname} = GirFFI::ArgHelper.ptr_to_utf8(#{cvar})" ]
      elsif specialized_type_tag == :c
        size = array_size
        [ "#{retname} = GirFFI::ArgHelper.ptr_to_typed_array #{subtype_tag_or_class_name}, #{cvar}, #{size}" ]
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

    def retname
      @retname ||= @var_gen.new_var
    end

    def has_conversion?
      needs_wrapping? || [ :utf8, :c ].include?(specialized_type_tag)
    end

    def needs_wrapping?
      [ :struct, :union, :interface, :object, :strv, :zero_terminated,
        :byte_array, :ptr_array, :glist, :gslist, :ghash, :array
      ].include?(specialized_type_tag)
    end

    def is_void_return_value?
      specialized_type_tag == :void && !type_info.pointer?
    end

    def return_value_conversion_arguments
      conversion_arguments cvar
    end
  end
end
