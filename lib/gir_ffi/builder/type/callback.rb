require 'gir_ffi/builder/type/base'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a callback type. The type will be
      # attached to the appropriate namespace module, and will be defined
      # as a callback for FFI.
      class Callback < Base
        def instantiate_class
          @klass = optionally_define_constant namespace_module, @classname do
            lib.callback callback_sym, argument_types, return_type
          end
        end

        def callback_sym
          @classname.to_sym
        end

        def argument_types
          @info.argument_ffi_types
        end

        def return_type
          Builder.ffi_function_return_type info
        end
      end
    end
  end
end
