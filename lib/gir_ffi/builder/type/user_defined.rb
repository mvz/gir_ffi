require 'gir_ffi/builder/type/unintrospectable'

module GirFFI
  module Builder
    module Type

      # Implements the creation of GObject subclasses from Ruby.
      class UserDefined < Unintrospectable
        def initialize klass, &block
          self.instance_eval(&block) if block_given?
          parent_type = klass.get_gtype
          query_result = GObject.type_query parent_type

          type_info = GObject::TypeInfo.new
          type_info.class_size = query_result.class_size
          type_info.instance_size = query_result.instance_size
          properties.each do
            type_info.instance_size += FFI.type_size(:int32)
          end

          new_type = GObject.type_register_static parent_type, klass.name, type_info, 0

          CACHE[new_type] = klass

          super new_type
        end

        def setup_class
          super
          setup_constructor
          setup_property_accessors
        end

        private

        def install_property pspec
          properties << pspec
        end

        def properties
          @properties ||= []
        end

        def layout_specification
          parent_spec = [:parent, superclass::Struct, 0]
          offset = superclass::Struct.size
          fields_spec = properties.map do |pspec|
            spec = [pspec.get_name, :int32, offset]
            offset += FFI.type_size(:int32)
            spec
          end.flatten(1)
          parent_spec + fields_spec
        end

        def setup_property_accessors
          properties.each do |pspec|
            setup_accessors_for_param_spec pspec
          end
        end

        def setup_accessors_for_param_spec pspec
          code = <<-CODE
          def #{pspec.get_name}
            @struct[:#{pspec.get_name}]
          end
          def #{pspec.get_name}= val
            @struct[:#{pspec.get_name}] = val
          end
          CODE

          @klass.class_eval code
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
          @klass.class_eval code
        end
      end
    end
  end
end

