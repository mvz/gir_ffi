module GirFFI
  module Builders
    # Builder that generates code to convert values from Ruby to C. Used by
    # argument builders.
    class RubyToCConvertor
      def initialize(type_info, argument_name)
        @type_info = type_info
        @argument_name = argument_name
      end

      def conversion
        args = conversion_arguments @argument_name
        "#{@type_info.argument_class_name}.from(#{args})"
      end

      def conversion_arguments(name)
        @type_info.extra_conversion_arguments.map(&:inspect).push(name).join(', ')
      end
    end
  end
end
