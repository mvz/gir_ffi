require 'gir_ffi/builder_helper'
require 'gir_ffi/builder/type/base'
require 'gir_ffi/builder/type/callback'
require 'gir_ffi/builder/type/enum'
require 'gir_ffi/builder/type/union'
require 'gir_ffi/builder/type/object'
require 'gir_ffi/builder/type/struct'
require 'gir_ffi/builder/type/interface'

module GirFFI
  # Builds a class based on information found in the introspection
  # repository.
  module Builder
    module Type
      def self.build info
        case info.info_type
        when :callback
          Callback
        when :enum, :flags
          Enum
        when :union
          Union
        when :object
          Object
        when :struct
          Struct
        when :interface
          Interface
        end.new(info).build_class
      end
    end
  end
end
