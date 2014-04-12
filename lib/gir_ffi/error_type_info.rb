require 'gir_ffi/info_ext/i_type_info'

module GirFFI
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
