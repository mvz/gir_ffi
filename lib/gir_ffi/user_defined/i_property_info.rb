require 'gir_ffi/user_defined/i_base_info'

module GirFFI
  module UserDefined
    class IPropertyInfo < IBaseInfo
      attr_accessor :property_type
    end
  end
end
