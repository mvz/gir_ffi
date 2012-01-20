require 'gir_ffi/builder/type/unintrospectable'

module GirFFI
  module Builder
    module Type

      # Implements the creation of GObject subclasses from Ruby.
      class UserDefined < Unintrospectable
        def initialize klass
          parent_type = klass.get_gtype
          query_result = GObject.type_query parent_type

          type_info = GObject::TypeInfo.new
          type_info.class_size = query_result.class_size
          type_info.instance_size = query_result.instance_size

          new_type = GObject.type_register_static parent_type, klass.name, type_info, 0

          CACHE[new_type] = klass

          super new_type
        end
      end
    end
  end
end

