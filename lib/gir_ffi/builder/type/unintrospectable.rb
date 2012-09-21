require 'gir_ffi/builder/type/object'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing an object type for
      # which no data is found in the GIR. Typically, these are created to
      # cast objects returned by a function that returns an interface.
      class Unintrospectable < Object
        # FIXME: Breaks parent interface.
        def initialize gtype
          @gtype = gtype
          @info = nil
        end

        def instantiate_class
          CACHE[@gtype] ||= Class.new(superclass)
          @klass = CACHE[@gtype]
          @structklass = get_or_define_class @klass, :Struct, layout_superclass
          setup_class unless already_set_up
        end

        def target_gtype
          @gtype
        end

        def setup_class
          setup_constants
          setup_layout
          setup_interfaces
          setup_gtype_getter
        end

        def setup_instance_method method
          false
        end

        private

        def superclass
          GirFFI::Builder.build_by_gtype parent_gtype
        end

        def parent
          gir.find_by_gtype parent_gtype
        end

        def parent_gtype
          GObject.type_parent @gtype
        end

        def fields
          []
        end

        def interface_infos
          interface_gtypes.map do |gtype|
            gir.find_by_gtype gtype
          end.compact
        end

        def interface_gtypes
          ::GObject.type_interfaces(@gtype)
        end

        def interfaces
          interface_infos.map do |info|
            GirFFI::Builder.build_class info
          end
        end

        def signal_definers
          interface_infos
        end
      end
    end
  end
end

