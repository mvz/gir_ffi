# frozen_string_literal: true
module GObjectIntrospection
  # Wraps a GIFieldInfo struct.
  # Represents a field of an IStructInfo or an IUnionInfo.
  class IFieldInfo < IBaseInfo
    def flags
      Lib.g_field_info_get_flags @gobj
    end

    def size
      Lib.g_field_info_get_size @gobj
    end

    def offset
      Lib.g_field_info_get_offset @gobj
    end

    def field_type
      ITypeInfo.wrap Lib.g_field_info_get_type(@gobj)
    end

    def readable?
      flags[:readable]
    end

    def writable?
      flags[:writable]
    end
  end
end
