# frozen_string_literal: true

module GirFFI
  module Builders
    # Implements a blank return value matching ReturnValueBuilder's interface.
    class NullReturnValueBuilder
      def initialize; end

      def array_length_idx
        -1
      end

      def capture_variable_name
        nil
      end

      def post_conversion
        []
      end
    end
  end
end
