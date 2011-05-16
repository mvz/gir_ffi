module GirFFI
  module Builder
    class DynamicType
      def initialize gtype
        @gtype = gtype
      end

      def build_class
        Class.new(parent)
      end

      private

      def parent
        parent_type = ::GObject.type_parent @gtype
        info = gir.find_by_gtype(parent_type)
        GirFFI::Builder.build_class info
      end

      def gir
        @gir ||= GirFFI::IRepository.default
      end
    end
  end
end
