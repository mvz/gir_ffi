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
          # XXX Don't use pointer directly to appease JRuby.
          if subtype == :pointer
            subtype = :"uint#{FFI.type_size(:pointer)*8}"
          end
          [subtype, array_fixed_size]
        else
          ffitype
        end
      end

      def element_type
        case tag
        when :glist, :gslist
          param_type 0
        when :ghash
          [param_type(0), param_type(1)]
        else
          nil
        end
      end
    end
  end
end

GObjectIntrospection::ITypeInfo.send :include, GirFFI::InfoExt::ITypeInfo
