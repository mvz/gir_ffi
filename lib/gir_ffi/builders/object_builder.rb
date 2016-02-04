require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/with_layout'
require 'gir_ffi/builders/property_builder'
require 'gir_ffi/object_base'

module GirFFI
  module Builders
    # Implements the creation of a class representing a GObject Object.
    class ObjectBuilder < RegisteredTypeBuilder
      include WithLayout

      # Dummy builder for the ObjectBase class
      class ObjectBaseBuilder
        def build_class
          ObjectBase
        end

        def ancestor_infos
          []
        end
      end

      def find_signal(signal_name)
        seek_in_ancestor_infos { |info| info.find_signal signal_name }
      end

      def find_property(property_name)
        seek_in_ancestor_infos { |info| info.find_property property_name }
      end

      def object_class_struct
        @object_class_struct ||= Builder.build_class object_class_struct_info
      end

      def ancestor_infos
        @ancestor_infos ||= [info] + info.interfaces + parent_ancestor_infos
      end

      def eligible_fields
        info.fields.select { |finfo|
          !info.find_instance_method("get_#{finfo.name}")
        }
      end

      protected

      def object_class_struct_info
        @object_class_struct_info ||=
          info.class_struct || parent_builder.object_class_struct_info
      end

      private

      def setup_class
        setup_layout
        setup_constants
        stub_methods
        setup_field_accessors
        setup_property_accessors
        setup_vfunc_invokers
        setup_interfaces
        provide_initializer
      end

      # FIXME: Private method only used in subclass
      def layout_superclass
        FFI::Struct
      end

      def parent_info
        unless defined? @parent_info
          @parent_info = if (parent = info.parent) && parent != info
                           parent
                         end
        end
        @parent_info
      end

      def superclass
        @superclass ||= parent_builder.build_class
      end

      def parent_builder
        @parent_builder ||= if parent_info
                              Builders::TypeBuilder.builder_for(parent_info)
                            else
                              ObjectBaseBuilder.new
                            end
      end

      def parent_ancestor_infos
        @parent_ancestor_infos ||= parent_builder.ancestor_infos
      end

      def setup_field_accessors
        fields.each do |finfo|
          next if info.find_property finfo.name
          next if finfo.name == 'parent_instance'
          FieldBuilder.new(finfo).build
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

      def define_vfunc_invoker(vfunc_name, invoker_name)
        return if vfunc_name == invoker_name
        klass.class_eval "
          def #{vfunc_name} *args, &block
            #{invoker_name}(*args, &block)
          end
        "
      end

      def provide_initializer
        return if info.find_method 'new'

        klass.class_eval "
          def initialize(properties = {})
            base_initialize(properties)
          end
        "
      end

      def setup_interfaces
        interfaces.each do |iface|
          klass.send :include, iface
        end
      end

      def interfaces
        info.interfaces.map do |ifinfo|
          GirFFI::Builder.build_class ifinfo
        end
      end

      def seek_in_ancestor_infos
        ancestor_infos.each do |info|
          item = yield info
          return item if item
        end
        nil
      end
    end
  end
end
