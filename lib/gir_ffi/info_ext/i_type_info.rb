require 'gir_ffi/builder_helper'

class GObjectIntrospection::ITypeInfo
  include GirFFI::BuilderHelper

  # FIXME: Create clearer name. Something to do with layout_specification.
  def ffitype_for_struct
    ffitype = GirFFI::Builder.itypeinfo_to_ffitype self
    if ffitype.kind_of?(Class) and const_defined_for ffitype, :Struct
      ffitype = ffitype.const_get :Struct
    end
    if ffitype == :bool
      ffitype = :int
    end
    if ffitype == :array
      subtype = param_type(0).ffitype_for_struct
      ffitype = [subtype, array_fixed_size]
    end
    ffitype
  end
end
