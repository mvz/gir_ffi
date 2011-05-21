module GirFFI
  module Builder
    class DynamicType
      CACHE = {}

      def initialize gtype
        @gtype = gtype
      end

      def build_class
        CACHE[@gtype] ||= Class.new(parent).tap do |klass|
          interfaces.each do |iface|
            klass.class_eval do
              include iface
            end
          end
          klass.const_set :GIR_FFI_BUILDER, self
        end
      end

      def setup_instance_method method
        interfaces.each do |iface|
          if iface.gir_ffi_builder.setup_instance_method method
            return true
          end
        end
        parent.gir_ffi_builder.setup_instance_method method
      end

      private

      def parent
        parent_type = ::GObject.type_parent @gtype
        info = gir.find_by_gtype(parent_type)
        GirFFI::Builder.build_class info
      end

      def interfaces
        iface_types = ::GObject.type_interfaces @gtype
        iface_types.map do |gtype|
          info = gir.find_by_gtype gtype
          GirFFI::Builder.build_class info
        end
      end

      def gir
        @gir ||= GirFFI::IRepository.default
      end
    end
  end
end
