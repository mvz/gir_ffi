module GObjectIntrospection
  # Wraps a GIEnumInfo struct, if it represents a flag type.
  # TODO: Perhaps just use IEnumInfo. Seems to make more sense.
  class IFlagsInfo < IEnumInfo
  end
end
