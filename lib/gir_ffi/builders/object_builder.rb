require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/with_layout'
require 'gir_ffi/builders/with_methods'
require 'gir_ffi/builders/property_builder'
require 'gir_ffi/object_base'

module GirFFI
  module Builders
    # Implements the creation of a class representing a GObject Object.
    class ObjectBuilder < RegisteredTypeBuilder
      include WithMethods
      include WithLayout

      def find_signal signal_name
        signal_definers.each do |inf|
          sig = inf.find_signal signal_name
          return sig if sig
        end
        superclass.find_signal signal_name or
          raise "Signal #{signal_name} not found"
      end

      def find_property property_name
        info.find_property property_name or
          superclass.find_property property_name or
          raise "Property #{property_name} not found"
      end

      def object_class_struct
        @object_class_struct ||= Builder.build_class object_class_struct_info
      end

      private

      def setup_class
        setup_layout
        setup_constants
        stub_methods
        if info.fundamental?
          setup_field_accessors
        else
          setup_property_accessors
        end
        setup_vfunc_invokers
        setup_interfaces
      end

      # FIXME: Private method only used in subclass
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
        @superclass ||= if parent
                          Builder.build_class parent
                        else
                          ObjectBase
                        end
      end

      def setup_property_accessors
        info.properties.each do |prop|
          PropertyBuilder.new(prop).build
        end
      end

      # TODO: Guard agains accidental invocation of undefined vfuncs.
      # TODO: Create object responsible for creating these invokers
      def setup_vfunc_invokers
        info.vfuncs.each do |vfinfo|
          if (invoker = vfinfo.invoker)
            define_vfunc_invoker vfinfo.name, invoker.name
          end
        end
      end

      def define_vfunc_invoker vfunc_name, invoker_name
        return if vfunc_name == invoker_name
        klass.class_eval "
          def #{vfunc_name} *args, &block
            #{invoker_name}(*args, &block)
          end
        "
      end

      def setup_interfaces
        interfaces.each do |iface|
          klass.send :include, iface
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

      def object_class_struct_info
        @object_class_struct_info ||= info.class_struct
      end
    end
  end
end
