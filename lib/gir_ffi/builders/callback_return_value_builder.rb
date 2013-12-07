require 'gir_ffi/builders/return_value_builder'

module GirFFI
  module Builders
    class CallbackReturnValueBuilder < BaseArgumentBuilder
      class Convertor
        def initialize type_info, argument_name
          @type_info = type_info
          @argument_name = argument_name
        end

        def conversion
          if conversion_needed?
            args = conversion_arguments @argument_name
            "#{@type_info.argument_class_name}.from(#{args})"
          else
            @argument_name
          end
        end

        def conversion_arguments name
          @type_info.extra_conversion_arguments.map(&:inspect).push(name).join(", ")
        end

        def conversion_needed?
          @type_info.flattened_tag == :enum ||
            [ :array, :byte_array, :c, :error, :filename, :ghash, :glist,
              :gslist, :interface, :object, :ptr_array, :struct, :strv, :union,
              :utf8, :zero_terminated ].include?(@type_info.flattened_tag)
        end
      end

      def post_conversion
        if has_post_conversion?
          [ "#{retname} = #{post_convertor.conversion}" ]
        else
          []
        end
      end

      def inarg
        nil
      end

      def retval
        super if is_relevant?
      end

      def is_relevant?
        !is_void_return_value? && !arginfo.skip?
      end

      def retname
        @retname ||= if has_post_conversion?
                       @var_gen.new_var
                     else
                       callarg
                     end
      end

      private

      def has_post_conversion?
        post_convertor.conversion_needed?
      end

      def post_convertor
        @post_convertor ||= Convertor.new(type_info, callarg)
      end

      def is_void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end
