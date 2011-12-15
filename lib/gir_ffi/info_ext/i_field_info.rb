require 'gir_ffi/info_ext/i_type_info'
class GObjectIntrospection::IFieldInfo
  def layout_specification
    [ name.to_sym,
      field_type.ffitype_for_struct,
      offset ]
  end
end

