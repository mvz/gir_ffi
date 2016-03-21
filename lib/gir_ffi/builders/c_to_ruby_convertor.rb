# frozen_string_literal: true
module GirFFI
  module Builders
    # Builder that generates code to convert values from C to Ruby. Used by
    # argument builders.
    class CToRubyConvertor
      def initialize(type_info, argument, length_arg, ownership_transfer: nil)
        @type_info = type_info
        @argument = argument
        @length_arg = length_arg
        @ownership_transfer = ownership_transfer
      end

      def conversion
        case @type_info.flattened_tag
        when :utf8, :filename
          if @ownership_transfer == :everything
            "#{@argument}.tap { |it| it.autorelease = true }.to_utf8"
          else
            "#{@argument}.to_utf8"
          end
        when :object
          base = "#{@type_info.argument_class_name}.wrap(#{conversion_argument_list})"
          @ownership_transfer == :nothing ? "#{base}.tap { |it| it && it.ref }" : base
        else
          "#{@type_info.argument_class_name}.#{conversion_method}(#{conversion_argument_list})"
        end
      end

      private

      def conversion_method
        case @type_info.flattened_tag
        when :struct, :union
          case @ownership_transfer
          when :everything
            'wrap_own'
          when :nothing
            'wrap_copy'
          else
            'wrap'
          end
        else
          'wrap'
        end
      end

      def conversion_argument_list
        conversion_arguments.join(', ')
      end

      def conversion_arguments
        case @type_info.flattened_tag
        when :c
          [@type_info.element_type.inspect, array_size, @argument]
        else
          @type_info.extra_conversion_arguments.map(&:inspect).push(@argument)
        end
      end

      def array_size
        if @length_arg
          @length_arg
        else
          @type_info.array_fixed_size
        end
      end
    end
  end
end
