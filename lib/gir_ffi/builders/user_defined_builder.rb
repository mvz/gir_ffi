require 'gir_ffi/builders/object_builder'
require 'gir_ffi/g_type'

module GirFFI
  module Builders
    # Implements the creation of GObject subclasses from Ruby.
    class UserDefinedBuilder < ObjectBuilder
      def initialize info
        @info = info
      end

      def instantiate_class
        if already_set_up
          @gtype = klass.get_gtype
        else
          @gtype = GObject.type_register_static(parent_gtype.to_i,
                                                info.g_name,
                                                gobject_type_info, 0)
          included_interfaces.each do |interface|
            ifinfo = gobject_interface_info interface
            GObject.type_add_interface_static @gtype, interface.get_gtype, ifinfo
          end
          setup_class
          TypeBuilder::CACHE[@gtype] = klass
        end
      end

      def setup_class
        setup_layout
        setup_constants
        #stub_methods
        setup_gtype_getter
        setup_property_accessors
        #setup_vfunc_invokers
        #setup_interfaces
        setup_constructor
      end

      def gtype
        @gtype
      end

      private

      # FIXME: Is this really used?
      def target_gtype
        @gtype
      end

      def parent
        @parent ||= gir.find_by_gtype(parent_gtype.to_i)
      end

      def parent_gtype
        @parent_gtype ||= GType.new(klass.superclass.get_gtype)
      end

      def interface_gtypes
        included_interfaces.map {|interface| GType.new(interface.get_gtype) }
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

      def gobject_interface_info interface
        GObject::InterfaceInfo.new.tap do |interface_info|
          interface_info.interface_init = interface_init_proc(interface)
        end
      end

      def class_init_proc
        proc do |object_class_ptr, data|
          setup_properties object_class_ptr
          setup_vfuncs object_class_ptr
        end
      end

      def interface_init_proc interface
        proc do |interface_ptr, data|
          setup_interface_vfuncs interface, interface_ptr
        end
      end

      def instance_size
        size = parent_gtype.instance_size
        properties.each do
          size += FFI.type_size(:int32)
        end
        return size
      end

      def class_size
        parent_gtype.class_size + interface_gtypes.map(&:class_size).inject(0, :+)
      end

      def setup_properties object_class_ptr
        object_class = GObject::ObjectClass.wrap object_class_ptr

        object_class.get_property = property_getter
        object_class.set_property = property_setter

        properties.each_with_index do |property, index|
          object_class.install_property index + 1, property.param_spec
        end
      end

      def property_getter
        proc do |object, property_id, value, pspec|
          value.set_value object.send(pspec.get_name)
        end
      end

      def property_setter
        proc do |object, property_id, value, pspec|
          object.send("#{pspec.get_name}=", value.get_value)
        end
      end

      def setup_vfuncs object_class_ptr
        super_class_struct = superclass.gir_ffi_builder.object_class_struct::Struct.new(object_class_ptr)

        info.vfunc_implementations.each do |impl|
          setup_vfunc super_class_struct, impl
        end
      end

      def setup_interface_vfuncs interface, interface_ptr
        interface_builder = interface.gir_ffi_builder

        interface_struct = interface_builder.interface_struct::Struct.new(interface_ptr)
        interface_info = interface_builder.info

        info.vfunc_implementations.each do |impl|
          setup_interface_vfunc interface_info, interface_struct, impl
        end
      end

      def setup_vfunc super_class_struct, impl
        vfunc_name = impl.name
        vfunc_info = parent.find_vfunc vfunc_name.to_s

        if vfunc_info
          install_vfunc super_class_struct, vfunc_name, vfunc_info, impl.implementation
        end
      end

      def setup_interface_vfunc interface_info, interface_struct, impl
        vfunc_name = impl.name
        vfunc_info = interface_info.find_vfunc vfunc_name.to_s

        if vfunc_info
          install_vfunc interface_struct, vfunc_name, vfunc_info, impl.implementation
        end
      end

      def install_vfunc container_struct, vfunc_name, vfunc_info, implementation
        vfunc = VFuncBuilder.new(vfunc_info).build_class
        # NOTE: This assigns a VFuncBase to a CallbackBase.
        # This suggests that the two should be combined, but it seems
        # CallbackBase will not cast the first argument correctly if used
        # to map the implementation proc arguments.
        container_struct[vfunc_name] = vfunc.from implementation
      end

      def properties
        info.properties
      end

      def layout_specification
        parent_spec = [:parent, superclass::Struct, 0]
        offset = superclass::Struct.size
        fields_spec = properties.map do |pinfo|
          spec = [pinfo.name.to_sym, :int32, offset]
          offset += FFI.type_size(:int32)
          spec
        end.flatten(1)
        parent_spec + fields_spec
      end

      def setup_property_accessors
        properties.each do |pinfo|
          setup_accessors_for_param_info pinfo
        end
      end

      def setup_accessors_for_param_info pinfo
        field_name = pinfo.name
        code = <<-CODE
        def #{field_name}
          @struct[:#{field_name}]
        end
        def #{field_name}= val
          @struct[:#{field_name}] = val
        end
        CODE

        klass.class_eval code
      end

      def method_introspection_data _method
        nil
      end

      def setup_constructor
        code = <<-CODE
        def self.new
          gptr = GObject::Lib.g_object_newv #{@gtype}, 0, nil
          self.wrap(gptr)
        end
        CODE
        klass.class_eval code
      end
    end
  end
end
