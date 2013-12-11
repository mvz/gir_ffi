require 'gir_ffi/builders/base_argument_builder'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values.
    class ReturnValueBuilder < BaseArgumentBuilder
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
            @length_arg.retname
          else
            @type_info.array_fixed_size
          end
        end
      end

      def initialize var_gen, arginfo, is_constructor = false
        super var_gen, arginfo
        @is_constructor = is_constructor
      end

      def post_conversion
        if has_post_conversion?
          [ "#{post_converted_name} = #{post_conversion_implementation}" ]
        else
          []
        end
      end

      def inarg
        nil
      end

      def return_value_name
        if is_relevant?
          post_converted_name unless array_arg
        end
      end

      def is_relevant?
        !is_void_return_value? && !arginfo.skip?
      end

      def post_converted_name
        @post_converted_name ||= if has_post_conversion?
                       @var_gen.new_var
                     else
                       capture_variable_name
                     end
      end

      def capture_variable_name
        @capture_variable_name ||= new_variable
      end

      private

      def has_post_conversion?
        is_closure || needs_constructor_wrap? ||
          type_info.needs_conversion_for_functions?
      end

      def post_convertor
        @post_convertor ||= Convertor.new(type_info, capture_variable_name, length_arg)
      end

      def post_conversion_implementation
        if is_closure
          "GirFFI::ArgHelper::OBJECT_STORE[#{capture_variable_name}.address]"
        elsif needs_constructor_wrap?
          "self.constructor_wrap(#{capture_variable_name})"
        else
          post_convertor.conversion
        end
      end

      def needs_constructor_wrap?
        @is_constructor && specialized_type_tag == :object
      end

      def is_void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end
