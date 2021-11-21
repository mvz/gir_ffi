# frozen_string_literal: true

module GirFFI
  module Builders
    # Builder that generates code to convert closure arguments ('user data')
    # from Ruby to C. Used by argument builders.
    #
    # GirFFI uses this to store a key to the storage of the related callback so
    # it can be cleaned by the default DestroyNotify object.
    class ClosureToPointerConvertor
      def initialize(argument_name)
        @argument_name = argument_name
      end

      def conversion
        "GirFFI::ArgHelper.store(#{@argument_name})"
      end
    end
  end
end
