# frozen_string_literal: true

require "gir_ffi/builders/registered_type_builder"
require "gir_ffi/builders/with_layout"
require "gir_ffi/builders/property_builder"
require "gir_ffi/builders/class_struct_builder"
require "gir_ffi/object_base"
require "gir_ffi/struct"

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

        def object_class_struct
          GObject::TypeClass
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
        @object_class_struct ||=
          if object_class_struct_info
            ClassStructBuilder.new(object_class_struct_info,
                                   parent_builder.object_class_struct).build_class
          else
            parent_builder.object_class_struct
          end
      end

      def ancestor_infos
        @ancestor_infos ||= [info] + info.interfaces + parent_ancestor_infos
      end

      def eligible_properties
        info.properties.reject do |pinfo|
          info.find_instance_method("get_#{pinfo.name}")
        end
      end

      protected

      def object_class_struct_info
        @object_class_struct_info ||= info.class_struct
      end

      private

      def setup_class
        setup_layout
        setup_constants
        stub_methods
        setup_property_accessors
        setup_vfunc_invokers
        setup_interfaces
        setup_initializer
      end

      # FIXME: Private method only used in subclass
      def layout_superclass
        GirFFI::Struct
      end

      def parent_info
        info.parent
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

      def setup_property_accessors
        eligible_properties.each do |prop|
          PropertyBuilder.new(prop).build
        end
      end

      # TODO: Guard agains accidental invocation of undefined vfuncs.
      # TODO: Create object responsible for creating these invokers
      def setup_vfunc_invokers
        info.vfuncs.each do |vfinfo|
          define_vfunc_invoker vfinfo.name, vfinfo.invoker_name if vfinfo.has_invoker?
        end
      end

      def define_vfunc_invoker(vfunc_name, invoker_name)
        return if vfunc_name == invoker_name

        klass.class_eval <<-DEF, __FILE__, __LINE__ + 1
          def #{vfunc_name} *args, &block
            #{invoker_name}(*args, &block)
          end
        DEF
      end

      def setup_initializer
        return if info.find_method "new"

        if info.abstract?
          define_abstract_initializer
        else
          define_default_initializer
        end
      end

      def define_abstract_initializer
        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def initialize(*)
            raise NoMethodError
          end
        RUBY
      end

      def define_default_initializer
        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def initialize(properties = {})
            base_initialize(properties)
          end
        RUBY
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
