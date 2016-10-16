# frozen_string_literal: true
require 'gir_ffi/builders/object_builder'
require 'gir_ffi/g_type'

module GirFFI
  module Builders
    # Implements the creation of GObject subclasses from Ruby.
    class UserDefinedBuilder < ObjectBuilder
      def initialize(info)
        @info = info
      end

      def setup_class
        setup_layout
        register_type
        setup_constants
        setup_property_accessors
        setup_constructor
        TypeBuilder::CACHE[@gtype] = klass
      end

      def target_gtype
        @gtype ||= klass.gtype
      end

      private

      def register_type
        @gtype = GObject.type_register_static(parent_gtype.to_i,
                                              info.g_name,
                                              gobject_type_info, 0)
        included_interfaces.each do |interface|
          ifinfo = gobject_interface_info interface
          GObject.type_add_interface_static @gtype, interface.gtype, ifinfo
        end
      end

      def parent_info
        @info.parent
      end

      def parent_gtype
        @info.parent_gtype
      end

      def interface_gtypes
        included_interfaces.map { |interface| GType.new(interface.gtype) }
      end

      def included_interfaces
        klass.included_modules - Object.included_modules
      end

      def klass
        @klass ||= @info.described_class
      end

      def gobject_type_info
        GObject::TypeInfo.new.tap do |type_info|
          type_info.class_size = class_size
          type_info.instance_size = instance_size
          type_info.class_init = class_init_proc
        end
      end

      def gobject_interface_info(interface)
        GObject::InterfaceInfo.new.tap do |interface_info|
          interface_info.interface_init = interface_init_proc(interface)
        end
      end

      def class_init_proc
        proc do |type_class_or_ptr, _data|
          object_class_ptr = type_class_or_ptr.to_ptr
          setup_properties object_class_ptr
          setup_vfuncs object_class_ptr
        end
      end

      def interface_init_proc(interface)
        proc do |interface_or_ptr, _data|
          interface_ptr = interface_or_ptr.to_ptr
          setup_interface_vfuncs interface, interface_ptr
        end
      end

      def instance_size
        size = parent_gtype.instance_size
        alignment = struct_class.alignment
        properties.each do |prop|
          type_size = FFI.type_size(prop.ffi_type)
          size += [type_size, alignment].max
        end
        size
      end

      def class_size
        parent_gtype.class_size + interface_gtypes.map(&:class_size).inject(0, :+)
      end

      def setup_properties(object_class_ptr)
        object_class = GObject::ObjectClass.wrap object_class_ptr

        object_class.get_property = property_getter
        object_class.set_property = property_setter

        properties.each_with_index do |property, index|
          object_class.install_property index + 1, property.param_spec
        end
      end

      def property_getter
        proc do |object, _property_id, value, pspec|
          value.set_value object.send(pspec.accessor_name)
        end
      end

      def property_setter
        proc do |object, _property_id, value, pspec|
          object.send("#{pspec.accessor_name}=", value.get_value)
        end
      end

      def setup_vfuncs(object_class_ptr)
        super_class_struct =
          superclass.gir_ffi_builder.object_class_struct::Struct.new(object_class_ptr)

        info.vfunc_implementations.each do |impl|
          setup_vfunc super_class_struct, impl
        end
      end

      def setup_interface_vfuncs(interface, interface_ptr)
        interface_builder = interface.gir_ffi_builder

        interface_struct = interface_builder.interface_struct::Struct.new(interface_ptr)
        interface_info = interface_builder.info

        info.vfunc_implementations.each do |impl|
          setup_interface_vfunc interface_info, interface_struct, impl
        end
      end

      def setup_vfunc(super_class_struct, impl)
        vfunc_name = impl.name
        vfunc_info = parent_info.find_vfunc vfunc_name.to_s

        if vfunc_info
          install_vfunc super_class_struct, vfunc_name, vfunc_info, impl.implementation
        end
      end

      def setup_interface_vfunc(interface_info, interface_struct, impl)
        vfunc_name = impl.name
        vfunc_info = interface_info.find_vfunc vfunc_name.to_s

        if vfunc_info
          install_vfunc interface_struct, vfunc_name, vfunc_info, impl.implementation
        end
      end

      def install_vfunc(container_struct, vfunc_name, vfunc_info, implementation)
        vfunc = VFuncBuilder.new(vfunc_info).build_class
        container_struct[vfunc_name] = vfunc.from implementation
      end

      def properties
        info.properties
      end

      def layout_specification
        parent_spec = [:parent, superclass::Struct]
        offset = parent_gtype.instance_size

        alignment = superclass::Struct.alignment
        fields_spec = properties.flat_map do |param_info|
          field_name = param_info.accessor_name
          ffi_type = param_info.ffi_type
          type_size = FFI.type_size(ffi_type)
          spec = [field_name, ffi_type, offset]
          offset += [type_size, alignment].max
          spec
        end
        parent_spec + fields_spec
      end

      # TODO: Move this to its own file.
      # TODO: See if this or FieldTypeInfo can be merged with with
      # UserDefinedPropertyInfo.
      class UserDefinedPropertyFieldInfo
        # Field info for user-defined property
        class FieldTypeInfo
          include InfoExt::ITypeInfo

          def initialize(property_info)
            @property_info = property_info
          end

          def tag
            @property_info.type_tag
          end

          def pointer?
            @property_info.pointer_type?
          end

          def interface_type
            @property_info.interface_type_tag if tag == :interface
          end

          def hidden_struct_type?
            false
          end

          def interface_class
            Builder.build_by_gtype @property_info.value_type if tag == :interface
          end

          def interface_class_name
            interface_class.name if tag == :interface
          end
        end

        def initialize(property_info, container, offset)
          @property_info = property_info
          @container = container
          @offset = offset
        end

        attr_reader :container, :offset

        def name
          @property_info.accessor_name
        end

        def field_type
          @field_type ||= FieldTypeInfo.new @property_info
        end

        def related_array_length_field
          nil
        end

        def writable?
          @property_info.writable?
        end
      end

      def setup_property_accessors
        offset = parent_gtype.instance_size
        alignment = struct_class.alignment
        properties.each do |param_info|
          field_info = UserDefinedPropertyFieldInfo.new(param_info, info, offset)
          type_size = FFI.type_size(param_info.ffi_type)
          offset += [type_size, alignment].max
          FieldBuilder.new(field_info, klass).build
        end
      end

      def method_introspection_data(_method)
        nil
      end

      def setup_constructor
        code = <<-CODE
        def initialize
          ptr = GObject::Lib.g_object_newv #{@gtype}, 0, nil
          store_pointer(ptr)
        end
        CODE
        klass.class_eval code
      end
    end
  end
end
