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

      def klass
        @klass ||= @info.described_class
      end

      def type_info
        type_info = GObject::TypeInfo.new
        type_info.class_size = parent_class_size 
        type_info.instance_size = instance_size

        type_info.class_init = proc do |object_class_ptr, data|
          object_class = GObject::ObjectClass.wrap(object_class_ptr.to_ptr)

          setup_properties(object_class)

          if info.vfunc_implementations.any?
            super_class_struct = superclass.gir_ffi_builder.object_class_struct::Struct.new(object_class_ptr)

            info.vfunc_implementations.each do |impl|
              vfunc_info = find_vfunc impl.name
              vfunc = VFuncBuilder.new(vfunc_info).build_class
              # FIXME: This assigns a VFuncBase to a CallbackBase.
              # This suggests that the two should be combined, but it seems
              # CallbackBase will not cast the first argument correctly if used
              # to map the implementation proc arguments.
              super_class_struct[impl.name] = vfunc.from impl.implementation
            end
          end
        end
        return type_info
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

      def setup_properties(object_class)
        object_class.set_property = proc do |object, property_id, value, pspec|
          object.send("#{pspec.get_name}=", value.get_value)
        end

        object_class.get_property = proc do |object, property_id, value, pspec|
          value.set_value object.send(pspec.get_name)
        end

        properties.each_with_index do |property, index|
          object_class.install_property index + 1, property.param_spec
        end
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
        code = <<-CODE
        def #{pinfo.name}
          @struct[:#{pinfo.name}]
        end
        def #{pinfo.name}= val
          @struct[:#{pinfo.name}] = val
        end
        CODE

        klass.class_eval code
      end

      def method_introspection_data method
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
