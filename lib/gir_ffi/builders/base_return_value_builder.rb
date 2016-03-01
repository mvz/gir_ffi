# frozen_string_literal: true
require 'gir_ffi/builders/base_argument_builder'

module GirFFI
  module Builders
    # Implements building post-processing statements for return values of
    # callbacks.
    class BaseReturnValueBuilder < BaseArgumentBuilder
      def relevant?
        !void_return_value? && !arginfo.skip?
      end

      def capture_variable_name
        @capture_variable_name ||= new_variable if relevant?
      end

      def void_return_value?
        specialized_type_tag == :void && !type_info.pointer?
      end
    end
  end
end

