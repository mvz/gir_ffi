require 'gir_ffi/builders/return_value_builder'

module GirFFI
  module Builders
    class CallbackReturnValueBuilder < BaseArgumentBuilder
      class Convertor
        def initialize type_info, builder
          @type_info = type_info
          @builder = builder
        end

        def conversion
          args = conversion_arguments @builder.callarg
          "#{@type_info.argument_class_name}.from(#{args})"
        end

        def conversion_arguments name
          @type_info.extra_conversion_arguments.map(&:inspect).push(name).join(", ")
        end
      end

      def needs_outgoing_parameter_conversion?
        specialized_type_tag == :enum || super
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

      def retval
        super if is_relevant?
      end

      def is_relevant?
        !is_void_return_value? && !arginfo.skip?
      end

      def retname
        @retname ||= if has_conversion?
                       @var_gen.new_var
                     else
                       callarg
                     end
      end

      private

      def has_conversion?
        is_closure || needs_outgoing_parameter_conversion?
      end

      def post_conversion
        Convertor.new(type_info, self).conversion
      end

      def is_void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end
