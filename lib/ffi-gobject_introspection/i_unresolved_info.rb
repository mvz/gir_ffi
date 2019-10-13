# frozen_string_literal: true

require "ffi-gobject_introspection/i_base_info"

module GObjectIntrospection
  # Wraps a GIBaseInfo struct in the case where the info type is :unresolved.
  class IUnresolvedInfo < IBaseInfo
  end
end
