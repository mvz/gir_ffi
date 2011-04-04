require 'gir_ffi/builder_helper'
require 'gir_ffi/builder/type/base'
require 'gir_ffi/builder/type/callback'
require 'gir_ffi/builder/type/enum'
require 'gir_ffi/builder/type/union'

module GirFFI
  # Builds a class based on information found in the introspection
  # repository.
  module Builder
    module Type
      def self.build info
        case info.type
        when :callback
          Callback
        when :enum, :flags
          Enum
        when :union
          Union
        else
          Base
        end.new(info).build_class
      end
    end
  end
end
