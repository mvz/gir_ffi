require 'gir_ffi/info_ext/i_type_info'

class GirFFI::UserDataTypeInfo
  include GirFFI::InfoExt::ITypeInfo

  def tag
    :void
  end

  def pointer?
    true
  end
end
