require 'gir_ffi/info_ext/full_type_name'

module GirFFI
  # Represents a boxed type not found in the GIR, conforming, as needed, to the
  # interface of GObjectIntrospection::IUnionInfo and GObjectIntrospection::IStructInfo.
  class UnintrospectableBoxedInfo
    attr_reader :g_type

    def initialize(gtype)
      @g_type = gtype
    end

    def info_type
      :unintrospectable_boxed
    end

    def safe_name
      GObject.type_name g_type
    end

    DEFAULT_BOXED_NAMESPACE = 'GLib'

    def namespace
      DEFAULT_BOXED_NAMESPACE
    end

    def fields
      []
    end
  end
end
