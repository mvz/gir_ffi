require 'gir_ffi/builder/type/base'
module GirFFI
  module Builder
    module Type

      # Implements the creation of a callback type. The type will be
      # attached to the appropriate namespace module, and will be defined
      # as a callback for FFI.
      class Callback < Base
        def build_class
          unless defined? @klass
            instantiate_callback_class
          end
          @klass
        end

        def instantiate_callback_class
          @klass = optionally_define_constant namespace_module, @classname do
            args = Builder.ffi_function_argument_types info
            ret = Builder.ffi_function_return_type info
            lib.callback @classname.to_sym, args, ret
          end
        end
      end
    end
  end
end
