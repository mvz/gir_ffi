# frozen_string_literal: true
require 'gir_ffi/info_ext/i_type_info'

module GirFFI
  # Represents the type of the user data (closure argument) of a signal or vfunc,
  # conforming, as needed, to the interface of GObjectIntrospection::ITypeInfo.
  class UserDataTypeInfo
    include InfoExt::ITypeInfo

    def tag
      :void
    end

    def pointer?
      true
    end

    def array_length
      -1
    end
  end
end
