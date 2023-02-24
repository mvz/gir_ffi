# frozen_string_literal: true

module GObjectIntrospection
  # Wraps a GIRegisteredTypeInfo struct.
  # Represents a registered type.
  class IRegisteredTypeInfo < IBaseInfo
    def type_name
      Lib.g_registered_type_info_get_type_name self
    end

    def type_init
      Lib.g_registered_type_info_get_type_init self
    end

    def g_type
      Lib.g_registered_type_info_get_g_type self
    end

    alias_method :gtype, :g_type
  end
end
