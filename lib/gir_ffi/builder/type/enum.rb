require 'gir_ffi/builder/type/registered_type'
module GirFFI
  module Builder
    module Type

      # Implements the creation of an enum or flags type. The type will be
      # attached to the appropriate namespace module, and will be defined
      # as an enum for FFI.
      class Enum < RegisteredType
        private

        def value_spec
          return info.values.map {|vinfo|
            val = GirFFI::ArgHelper.cast_uint32_to_int32(vinfo.value)
            [vinfo.name.to_sym, val]
          }.flatten
        end

        def instantiate_class
          if const_defined_for namespace_module, @classname
            @klass = namespace_module.const_get @classname
          else
            @klass = namespace_module.const_set @classname,
              lib.enum(@classname.to_sym, value_spec)
            setup_gtype_getter
          end
        end
      end
    end
  end
end

