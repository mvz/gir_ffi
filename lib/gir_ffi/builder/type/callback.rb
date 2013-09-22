require 'gir_ffi/builder/type/base'
require 'gir_ffi/callback_base'

module GirFFI
  module Builder
    module Type

      # Implements the creation of a callback type. The type will be
      # attached to the appropriate namespace module, and will be defined
      # as a callback for FFI.
      class Callback < Base
        def instantiate_class
          @klass ||= get_or_define_class namespace_module, @classname, CallbackBase
          @callback ||= optionally_define_constant @klass, :Callback do
            lib.callback callback_sym, argument_types, return_type
          end
          setup_constants unless already_set_up
          @klass
        end

        def callback_sym
          @classname.to_sym
        end

        def argument_types
          @info.argument_ffi_types
        end

        def return_type
          @info.return_ffi_type
        end
      end
    end
  end
end
