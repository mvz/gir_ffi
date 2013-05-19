require 'gir_ffi/builder/type/registered_type'
require 'gir_ffi/builder/type/with_layout'
require 'gir_ffi/builder/type/with_methods'
require 'gir_ffi/builder/property'
require 'gir_ffi/object_base'

module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing a GObject Object.
      class Object < RegisteredType
        include WithMethods
        include WithLayout

        def find_signal signal_name
          signal_definers.each do |inf|
            inf.signals.each do |sig|
              return sig if sig.name == signal_name
            end
          end
          if parent
            return superclass.find_signal signal_name
          end
          raise "Signal #{signal_name} not found"
        end

        def find_property property_name
          info.properties.each do |prop|
            return prop if prop.name == property_name
          end
          if parent
            return superclass.find_property property_name
          end
          raise "Property #{property_name} not found"
        end

        private

        def setup_class
          setup_layout
          setup_constants
          stub_methods
          setup_gtype_getter
          if info.fundamental?
            setup_field_accessors
          else
            setup_property_accessors
          end
          setup_vfunc_invokers
          setup_interfaces
        end

        # FIXME: Private method only in subclass
        def layout_superclass
          FFI::Struct
        end

        def parent
          unless defined? @parent
            pr = info.parent
            if pr.nil? or (pr.safe_name == @classname and pr.namespace == @namespace)
              @parent = nil
            else
              @parent = pr
            end
          end
          @parent
        end

        def superclass
          unless defined? @superclass
            if parent
              @superclass = Builder.build_class parent
            else
              @superclass = ObjectBase
            end
          end
          @superclass
        end

        def setup_property_accessors
          info.properties.each do |prop|
            setup_accessors_for_property_info prop
          end
        end

        def setup_accessors_for_property_info prop
          builder = Builder::Property.new prop
          unless has_instance_method prop.getter_name
            @klass.class_eval builder.getter_def
          end
          @klass.class_eval builder.setter_def
        end

        # TODO: Guard agains accidental invocation of undefined vfuncs.
        def setup_vfunc_invokers
          info.vfuncs.each do |vfinfo|
            invoker = vfinfo.invoker
            next if invoker.nil?
            next if invoker.name == vfinfo.name

            @klass.class_eval "
              def #{vfinfo.name} *args, &block
                #{invoker.name}(*args, &block)
              end
            "
          end
        end

        def setup_interfaces
          interfaces.each do |iface|
            @klass.class_eval do
              include iface
            end
          end
        end

        def signal_definers
          [info] + info.interfaces
        end

        def interfaces
          info.interfaces.map do |ifinfo|
            GirFFI::Builder.build_class ifinfo
          end
        end
      end
    end
  end
end

