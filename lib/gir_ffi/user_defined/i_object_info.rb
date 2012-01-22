require 'gir_ffi/user_defined/i_registered_type_info'

module GirFFI
  module UserDefined
    class IObjectInfo < IRegisteredTypeInfo
      attr_accessor :properties
      def initialize
        @properties = []
      end
    end
  end
end

