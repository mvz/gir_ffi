module GirFFI
  module Builders
    # Builder that generates code to convert closure arguments ('user data')
    # from C to Ruby. Used by argument builders.
    class ClosureConvertor
      def initialize argument_name
        @argument_name = argument_name
      end

      def conversion
        "GirFFI::ArgHelper::OBJECT_STORE.fetch(#{@argument_name})"
      end
    end
  end
end
