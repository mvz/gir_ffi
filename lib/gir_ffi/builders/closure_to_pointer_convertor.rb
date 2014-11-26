module GirFFI
  module Builders
    # Builder that generates code to convert closure arguments ('user data')
    # from Ruby to C. Used by argument builders.
    class ClosureToPointerConvertor
      def initialize argument_name
        @argument_name = argument_name
      end

      def conversion
        "GirFFI::InPointer.from_closure_data(#{@argument_name})"
      end
    end
  end
end
