require 'gir_ffi/builders/return_value_builder'

module GirFFI
  module Builders
    class CallbackArgumentBuilder < BaseArgumentBuilder
      class Convertor
        def initialize type_info, argument_name, length_arg
          @type_info = type_info
          @argument_name = argument_name
          @length_arg = length_arg
        end

        def conversion
          case @type_info.flattened_tag
          when :utf8, :filename
            "#{@argument_name}.to_utf8"
          else
            "#{@type_info.argument_class_name}.wrap(#{conversion_arguments})"
          end
        end

        private

        def conversion_arguments
          if @type_info.flattened_tag == :c
            "#{@type_info.subtype_tag_or_class.inspect}, #{array_size}, #{@argument_name}"
          else
            @type_info.extra_conversion_arguments.map(&:inspect).push(@argument_name).join(", ")
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

      def pre_conversion
        if has_pre_conversion?
          [ "#{pre_converted_name} = #{pre_conversion_implementation}" ]
        else
          []
        end
      end

      def call_argument_name
        pre_converted_name unless array_arg
      end

      def pre_converted_name
        @pre_converted_name ||= if has_pre_conversion?
                                  new_variable
                                else
                                  method_argument_name
                                end
      end

      def method_argument_name
        @method_argument_name ||= name || new_variable
      end

      private

      def has_pre_conversion?
        is_closure || type_info.needs_conversion_for_callbacks?
      end

      def pre_convertor
        @pre_convertor ||= Convertor.new(type_info, method_argument_name, length_argument_name)
      end

      def length_argument_name
        length_arg && length_arg.pre_converted_name
      end

      def pre_conversion_implementation
        if is_closure
          "GirFFI::ArgHelper::OBJECT_STORE[#{method_argument_name}.address]"
        else
          pre_convertor.conversion
        end
      end

      def is_void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end
