require 'gir_ffi/builder/type/struct_based'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a class representing a GObject Object.
      class Object < StructBased
        def setup_method method
          if super
            return true
          else
            if parent
              return superclass._setup_method method
            else
              return false
            end
          end
        end

        def setup_instance_method method
          if super
            return true
          else
            setup_instance_method_in_ancestor method
          end
        end

        def find_signal signal_name
          signal_definers.each do |inf|
            inf.signals.each do |sig|
              return sig if sig.name == signal_name
            end
          end
          if parent
            return superclass._find_signal signal_name
          end
          raise "Signal #{signal_name} not found"
        end

        def find_property property_name
          info.properties.each do |prop|
            return prop if prop.name == property_name
          end
          if parent
            return superclass._find_property property_name
          end
        end

        private

        def setup_instance_method_in_ancestor method
          interfaces.each do |iface|
            if iface._setup_instance_method method
              return true
            end
          end
          if parent
            return superclass._setup_instance_method method
          else
            return false
          end
        end

        def setup_class
          super
          setup_vfunc_invokers
          setup_interfaces
        end

        def parent
          unless defined? @parent
            pr = info.parent
            if pr.nil? or (pr.name == @classname and pr.namespace == @namespace)
              @parent = nil
            else
              @parent = pr
            end
          end
          @parent
        end

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

