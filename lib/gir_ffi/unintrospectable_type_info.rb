module GirFFI
  class UnintrospectableTypeInfo
    def initialize gtype, gir = GObjectIntrospection::IRepository.default, gobject = ::GObject
      @gtype = gtype
      @gir = gir
      @gobject = gobject
    end

    def interfaces
      @gobject.type_interfaces(@gtype).map do |gtype|
        @gir.find_by_gtype gtype
      end.compact
    end
  end
end
