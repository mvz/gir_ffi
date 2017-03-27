# frozen_string_literal: true

module GirFFI
  module Builders
    # Builder that generates code to convert values from Ruby to C. Used by
    # argument builders.
    class RubyToCConvertor
      def initialize(type_info, argument_name, ownership_transfer: nil)
        @type_info = type_info
        @argument_name = argument_name
        @ownership_transfer = ownership_transfer
      end

      def conversion
        args = conversion_arguments @argument_name
        "#{@type_info.argument_class_name}.#{conversion_method}(#{args})"
      end

      def conversion_arguments(name)
        @type_info.extra_conversion_arguments.map(&:inspect).push(name).join(', ')
      end

      private

      def conversion_method
        case @type_info.flattened_tag
        when :utf8
          'from_utf8'
        when :struct, :c
          case @ownership_transfer
          when :everything
            'copy_from'
          else
            'from'
          end
        else
          'from'
        end
      end
    end
  end
end
