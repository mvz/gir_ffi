require 'gir_ffi/builder/type/base'
module GirFFI
  module Builder
    module Type

      # Base class for type builders building types specified by subtypes
      # of IRegisteredTypeInfo. These are types whose C representation is
      # complex, i.e., a struct or a union.
      class RegisteredType < Base
      end
    end
  end
end



