# frozen_string_literal: true

module GirFFI
  module Builders
    # Builder that generates code to convert closure arguments ('user data')
    # from Ruby to C. Used by argument builders.
    class ClosureToPointerConvertor
      def initialize(argument_name, callback_argument)
        @argument_name = argument_name
        @callback_argument = callback_argument
      end

      def conversion
        "GirFFI::ArgHelper.store(#{callback_argument_name})"
      end

      private

      def callback_argument_name
        @callback_argument.call_argument_name
      end
    end
  end
end
