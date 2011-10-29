require 'gir_ffi/builder_helper'
require 'gir_ffi/builder/type/base'
require 'gir_ffi/builder/type/callback'
require 'gir_ffi/builder/type/constant'
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
      TYPE_MAP = {
        :callback => Callback,
        :constant => Constant,
        :enum => Enum,
        :flags => Enum,
        :interface => Interface,
        :object => Object,
        :struct => Struct,
        :union => Union
      }

      def self.build info
        TYPE_MAP[info.info_type].new(info).build_class
      end

      def self.builder_for info
        TYPE_MAP[info.info_type].new(info)
      end
    end
  end
end
