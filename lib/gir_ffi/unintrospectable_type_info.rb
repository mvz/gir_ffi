module GirFFI
  class UnintrospectableTypeInfo
    attr_reader :g_type

    def initialize gtype, gir = GObjectIntrospection::IRepository.default, gobject = ::GObject
      @g_type = gtype
      @gir = gir
      @gobject = gobject
    end

    def safe_name
      @gobject.type_name @g_type
    end

    def parent
      @gir.find_by_gtype @gobject.type_parent(@g_type)
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
  end
end
