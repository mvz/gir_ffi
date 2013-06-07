require 'gir_ffi/builder_helper'

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::IArgInfo needed by GirFFI
    module ITypeInfo
      include BuilderHelper

      def g_type
        tag = self.tag
        case tag
        when :interface
          interface.g_type
        else
          GObject::TYPE_TAG_TO_GTYPE[tag]
        end
      end

      def make_g_value
        GObject::Value.for_g_type g_type
      end

      def layout_specification_type
        ffitype = self.to_ffitype
        case ffitype
        when Class
          ffitype.const_get :Struct
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
          subtype_tag_or_class 0
        when :ghash
          [subtype_tag_or_class(0), subtype_tag_or_class(1)]
        else
          nil
        end
      end

      def interface_type_name
        interface.full_type_name
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
          zero_terminated_array_type
        else
          array_type
        end
      end

      # TODO: Merge with subtype_tag_or_class
      def subtype_tag_or_class_name index = 0
        type = self.param_type index
        tag = type.tag
        base = if tag == :interface
                 type.interface_type_name
               else
                 tag.inspect
               end
        if type.pointer? && tag != :utf8 && tag != :filename
          "[:pointer, #{base}]"
        else
          base
        end
      end

      def subtype_tag_or_class index = 0
        type = self.param_type index
        type.tag_or_class
      end

      def tag_or_class_name
        type_tag = self.tag
        base = if type_tag == :interface
                 interface_type_name
               else
                 type_tag.inspect
               end
        if pointer? && type_tag != :utf8 && type_tag != :filename
          "[:pointer, #{base}]"
        else
          base
        end
      end

      def tag_or_class
        type_tag = self.tag
        base = if type_tag == :interface
                 Builder.build_class interface
               else
                 type_tag
               end
        if pointer? && type_tag != :utf8 && type_tag != :filename
          [:pointer, base]
        else
          base
        end
      end

      def to_ffitype
        return :pointer if pointer?

        type_tag = tag
        if type_tag == :interface
          Builder.build_class interface
        else
          TypeMap.map_basic_type type_tag
        end
      end

      private

      def zero_terminated_array_type
        case element_type
        when :utf8, :filename
          :strv
        else
          # TODO: Check that array_type == :c
          :zero_terminated
        end
      end
    end
  end
end

GObjectIntrospection::ITypeInfo.send :include, GirFFI::InfoExt::ITypeInfo
