require 'gir_ffi/info_ext/full_type_name'

module GirFFI
  # Represents a type not found in the GIR, conforming, as needed, to the
  # interface of GObjectIntrospection::IObjectInfo.
  class UnintrospectableTypeInfo
    attr_reader :g_type

    def initialize(gtype,
                   gir = GObjectIntrospection::IRepository.default,
                   gobject = GObject)
      @g_type = gtype
      @gir = gir
      @gobject = gobject
    end

    def info_type
      :unintrospectable
    end

    def safe_name
      @gobject.type_name @g_type
    end

    def parent
      @gir.find_by_gtype(parent_gtype) || self.class.new(parent_gtype, @gir, @gobject)
    end

    def parent_gtype
      @parent_gtype ||= @gobject.type_parent @g_type
    end

    def namespace
      parent.namespace
    end

    def interfaces
      @gobject.type_interfaces(@g_type).map do |gtype|
        @gir.find_by_gtype gtype
      end.compact
    end

    def fields
      []
    end

    def find_signal(_any)
      nil
    end
  end
end
