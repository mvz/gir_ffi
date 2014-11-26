module GirFFI
  module Builders
    # Argument convertor that does nothing
    class NullConvertor
      def initialize argument_name
        @argument_name = argument_name
      end

      def conversion
        @argument_name
      end
    end
  end
end
