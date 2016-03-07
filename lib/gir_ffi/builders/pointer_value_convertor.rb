# frozen_string_literal: true
module GirFFI
  module Builders
    # Encapsulates knowledge about how to store values in pointers, and how to
    # fetch values from pointers.
    class PointerValueConvertor
      def initialize(type_spec)
        @type_spec = type_spec
      end

      def pointer_to_value(ptr_exp)
        case ffi_type_spec
        when Module
          "#{ffi_type_spec}.get_value_from_pointer(#{ptr_exp}, 0)"
        when Symbol
          "#{ptr_exp}.get_#{ffi_type_spec}(0)"
        end
      end

      def value_to_pointer(ptr_exp, value_exp)
        case ffi_type_spec
        when Module
          "#{ffi_type_spec}.copy_value_to_pointer(#{value_exp}, #{ptr_exp})"
        when Symbol
          "#{ptr_exp}.put_#{ffi_type_spec} 0, #{value_exp}"
        end
      end

      private

      attr_reader :type_spec

      def ffi_type_spec
        TypeMap.type_specification_to_ffi_type type_spec
      end
    end
  end
end

