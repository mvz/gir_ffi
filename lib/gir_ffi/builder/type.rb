require 'gir_ffi/builder_helper'
require 'gir_ffi/builder/type/base'
require 'gir_ffi/builder/type/callback'

module GirFFI
  # Builds a class based on information found in the introspection
  # repository.
  module Builder
    module Type
      def self.build info
        case info.type
        when :callback
          Callback.new(info).build_class
        else
          Base.new(info).build_class
        end
      end
    end
  end
end
