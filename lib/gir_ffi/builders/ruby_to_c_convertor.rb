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
        method = case @ownership_transfer
                 when :everything
                   @type_info.ingoing_argument_conversion_method_transfer_everything
                 else
                   @type_info.ingoing_argument_conversion_method_transfer_nothing
                 end
        "#{@type_info.argument_class_name}.#{method}(#{args})"
      end

      def conversion_arguments(name)
        @type_info.extra_conversion_arguments.map(&:inspect).push(name).join(', ')
      end
    end
  end
end
