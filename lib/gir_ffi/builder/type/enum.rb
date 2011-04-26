require 'gir_ffi/builder/type/base'
module GirFFI
  module Builder
    module Type

      # Implements the creation of an enum or flags type. The type will be
      # attached to the appropriate namespace module, and will be defined
      # as an enum for FFI.
      class Enum < Base
        def build_class
          unless defined? @klass
            instantiate_enum_class
          end
          @klass
        end

        def value_spec
          return info.values.map {|vinfo|
            val = vinfo.value
            val = -(0x100000000-val) if val >= 0x80000000
            [vinfo.name.to_sym, val]
          }.flatten
        end

        def instantiate_enum_class
          @klass = optionally_define_constant namespace_module, @classname do
            lib.enum(@classname.to_sym, value_spec)
          end
        end
      end
    end
  end
end

