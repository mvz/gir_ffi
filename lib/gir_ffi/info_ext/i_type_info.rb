require 'gir_ffi/builder_helper'

module GirFFI
  module InfoExt
    module ITypeInfo
      include BuilderHelper

      def layout_specification_type
        ffitype = GirFFI::Builder.itypeinfo_to_ffitype self
        if ffitype.kind_of?(Class) and const_defined_for ffitype, :Struct
          ffitype = ffitype.const_get :Struct
        end
        if ffitype == :bool
          ffitype = :int
        end
        if ffitype == :array
          subtype = param_type(0).layout_specification_type
          ffitype = [subtype, array_fixed_size]
        end
        ffitype
      end
    end
  end
end

GObjectIntrospection::ITypeInfo.send :include, GirFFI::InfoExt::ITypeInfo
