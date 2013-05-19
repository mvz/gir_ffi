module GirFFI
  class UnintrospectableTypeInfo
    attr_reader :g_type

    def initialize gtype, gir = GObjectIntrospection::IRepository.default, gobject = ::GObject
      @g_type = gtype
      @gir = gir
      @gobject = gobject
    end

    def interfaces
      @gobject.type_interfaces(@g_type).map do |gtype|
        @gir.find_by_gtype gtype
      end.compact
    end
  end
end
