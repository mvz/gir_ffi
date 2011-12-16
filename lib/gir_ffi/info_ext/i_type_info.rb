require 'gir_ffi/builder_helper'

module GirFFI
  module InfoExt
    module ITypeInfo
      include BuilderHelper

      def layout_specification_type
        ffitype = GirFFI::Builder.itypeinfo_to_ffitype self
        case ffitype
        when Class
          ffitype.const_get :Struct
        when :bool
          :int
        when :array
          subtype = param_type(0).layout_specification_type
          [subtype, array_fixed_size]
        else
          ffitype
        end
      end
    end
  end
end

GObjectIntrospection::ITypeInfo.send :include, GirFFI::InfoExt::ITypeInfo
