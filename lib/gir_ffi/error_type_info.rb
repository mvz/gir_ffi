require 'gir_ffi/info_ext/i_type_info'

module GirFFI
  # Represents the type of an error argument for callbacks and functions,
  # conforming, as needed, to the interface of GObjectIntrospection::ITypeInfo
  class ErrorTypeInfo
    include GirFFI::InfoExt::ITypeInfo

    def array_length
      -1
    end

    def tag
      :error
    end

    def pointer?
      true
    end
  end
end
