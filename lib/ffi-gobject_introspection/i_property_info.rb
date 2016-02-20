# frozen_string_literal: true
module GObjectIntrospection
  # Wraps a GIPropertyInfo struct.
  # Represents a property of an IObjectInfo or an IInterfaceInfo.
  class IPropertyInfo < IBaseInfo
    def property_type
      ITypeInfo.wrap Lib.g_property_info_get_type(@gobj)
    end

    def flags
      Lib.g_property_info_get_flags @gobj
    end

    def readable?
      flags[:readable]
    end

    def writeable?
      flags[:writable]
    end

    def construct?
      flags[:construct]
    end

    def construct_only?
      flags[:construct_only]
    end
  end
end
