# frozen_string_literal: true
module GObjectIntrospection
  # Wraps a GIValueInfo struct.
  # Represents one of the enum values of an IEnumInfo.
  class IValueInfo < IBaseInfo
    def value
      Lib.g_value_info_get_value @gobj
    end
  end
end
