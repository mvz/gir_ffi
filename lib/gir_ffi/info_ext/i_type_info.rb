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
        when :glist, :gslist, :array
          subtype_tag 0
        when :ghash
          [subtype_tag(0), subtype_tag(1)]
        else
          nil
        end
      end

      def interface_type_name
        interface.full_type_name
      end

      def type_specification
        tag = self.tag
        if tag == :array
          "[#{flattened_array_type.inspect}, #{element_type.inspect}]"
        else
          tag.inspect
        end
      end

      def flattened_tag
        case tag
        when :interface
          interface_type
        when :array
          flattened_array_type
        else
          tag
        end
      end

      def interface_type
        interface.info_type
      end

      def flattened_array_type
        if zero_terminated?
          :strv
        else
          array_type
        end
      end

      private

      def subtype_tag index
        st = param_type(index)
        tag = st.tag
        case tag
        when :interface
          return :interface_pointer if st.pointer?
          return :interface
        when :void
          return :gpointer if st.pointer?
          return :void
        else
          return tag
        end
      end
    end
  end
end

GObjectIntrospection::ITypeInfo.send :include, GirFFI::InfoExt::ITypeInfo
