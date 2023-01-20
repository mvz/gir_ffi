# frozen_string_literal: true

module GirFFI
  module Builders
    # Encapsulates knowledge about how to store values in pointers, and how to
    # fetch values from pointers.
    class PointerValueConvertor
      def initialize(type_spec)
        @type_spec = type_spec
      end

      def pointer_to_value(ptr_exp, offset = 0)
        case ffi_type_spec
        when Module
          "#{ffi_type_spec}.get_value_from_pointer(#{ptr_exp}, #{offset})"
        when Symbol
          "#{ptr_exp}.get_#{ffi_type_spec}(#{offset})"
        end
      end

      def value_to_pointer(ptr_exp, value_exp, offset = 0)
        case ffi_type_spec
        when Module
          args = [value_exp, ptr_exp]
          args << offset unless offset == 0
          "#{ffi_type_spec}.copy_value_to_pointer(#{args.join(", ")})"
        when Symbol
          "#{ptr_exp}.put_#{ffi_type_spec} #{offset}, #{value_exp}"
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
