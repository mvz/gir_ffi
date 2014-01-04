require 'gir_ffi/builders/object_builder'

module GirFFI
  module Builders
    # Implements the creation of GObject subclasses from Ruby.
    class UserDefinedBuilder < ObjectBuilder
      def initialize info
        @info = info
      end

      def instantiate_class
        @gtype = GObject.type_register_static(parent_gtype, info.g_name,
                                              type_info, 0)
        interface_gtypes.each do |gt|
          ifinfo = GObject::InterfaceInfo.new
          GObject.type_add_interface_static @gtype, gt, ifinfo
        end
        setup_class unless already_set_up
        TypeBuilder::CACHE[@gtype] = klass
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

      def find_vfunc vfunc_name
        parent.find_vfunc vfunc_name.to_s
      end

      private

      def target_gtype
        @gtype
      end

      def parent
        @parent ||= gir.find_by_gtype(parent_gtype)
      end

      def parent_gtype
        @parent_gtype ||= klass.superclass.get_gtype
      end

      def interface_gtypes
        included_interfaces.map(&:get_gtype)
      end

      def included_interfaces
        klass.included_modules - Object.included_modules
      end

      def klass
        @klass ||= @info.described_class
      end

      def type_info
        GObject::TypeInfo.new.tap do |type_info|
          type_info.class_size = parent_class_size
          type_info.instance_size = instance_size
          type_info.class_init = class_init_proc
        end
      end

      def class_init_proc
        proc do |object_class_ptr, data|
          setup_properties object_class_ptr
          setup_vfuncs object_class_ptr
        end
      end

      def instance_size
        size = parent_instance_size
        properties.each do
          size += FFI.type_size(:int32)
        end
        return size
      end

      def parent_instance_size
        parent_query.instance_size
      end

      def parent_class_size
        parent_query.class_size
      end

      def parent_query
        @parent_query ||= GObject.type_query parent_gtype
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

      def setup_vfunc super_class_struct, impl
        vfunc_name = impl.name
        vfunc_info = find_vfunc vfunc_name
        vfunc = VFuncBuilder.new(vfunc_info).build_class
        # NOTE: This assigns a VFuncBase to a CallbackBase.
        # This suggests that the two should be combined, but it seems
        # CallbackBase will not cast the first argument correctly if used
        # to map the implementation proc arguments.
        super_class_struct[vfunc_name] = vfunc.from impl.implementation
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
