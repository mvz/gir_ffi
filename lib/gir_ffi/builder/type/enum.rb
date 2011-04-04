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

        def instantiate_enum_class
          @klass = optionally_define_constant namespace_module, @classname do
            vals = info.values.map {|vinfo| [vinfo.name.to_sym, vinfo.value]}.flatten
            lib.enum(@classname.to_sym, vals)
          end
        end
      end
    end
  end
end

