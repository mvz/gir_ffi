# frozen_string_literal: true

require 'gir_ffi/builder_helper'

module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::ITypeInfo needed by GirFFI
    module ITypeInfo
      def gtype
        TypeMap.type_info_to_gtype self
      end

      def make_g_value
        GObject::Value.for_gtype gtype
      end

      def element_type
        case tag
        when :glist, :gslist, :array, :c
          enumerable_element_type
        when :ghash
          dictionary_element_type
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
        tag == :interface && interface.info_type
      end

      def hidden_struct_type?
        flattened_tag == :struct && interface.empty?
      end

      def tag_or_class
        base = case tag
               when :interface
                 interface_class
               when :ghash
                 [tag, *element_type]
               else
                 flattened_tag
               end
        if pointer? && tag != :utf8 && tag != :filename
          [:pointer, base]
        else
          base
        end
      end

      def interface_class
        Builder.build_class interface if tag == :interface
      end

      TAG_TO_WRAPPER_CLASS_MAP = {
        array:           'GLib::Array',
        byte_array:      'GLib::ByteArray',
        c:               'GirFFI::SizedArray',
        error:           'GLib::Error',
        ghash:           'GLib::HashTable',
        glist:           'GLib::List',
        gslist:          'GLib::SList',
        ptr_array:       'GLib::PtrArray',
        strv:            'GLib::Strv',
        utf8:            'GirFFI::InPointer', # TODO: Create a string-like class
        void:            'GirFFI::InPointer', # TODO: Create a void-pointer class
        zero_terminated: 'GirFFI::ZeroTerminated'
      }.freeze

      # TODO: Use class rather than class name
      def argument_class_name
        interface_class_name ||
          TAG_TO_WRAPPER_CLASS_MAP[flattened_tag]
      end

      def interface_class_name
        interface.full_type_name if tag == :interface
      end

      def to_ffi_type
        return :pointer if pointer?

        case tag
        when :interface
          interface.to_ffi_type
        when :array
          [subtype_ffi_type(0), array_fixed_size]
        else
          TypeMap.map_basic_type tag
        end
      end

      def to_callback_ffi_type
        return :pointer if pointer?

        case tag
        when :interface
          interface.to_callback_ffi_type
        when :gboolean
          # TODO: Move this logic into TypeMap
          :bool
        else
          TypeMap.map_basic_type tag
        end
      end

      TAGS_NEEDING_RUBY_TO_C_CONVERSION = [
        :array, :c, :callback, :enum, :error, :ghash, :glist, :gslist, :object,
        :ptr_array, :struct, :strv, :utf8, :zero_terminated
      ].freeze

      TAGS_NEEDING_C_TO_RUBY_CONVERSION = [
        :array, :byte_array, :c, :error, :filename, :ghash, :glist, :gslist,
        :interface, :object, :ptr_array, :struct, :strv, :union, :utf8,
        :zero_terminated
      ].freeze

      def needs_ruby_to_c_conversion_for_functions?
        TAGS_NEEDING_RUBY_TO_C_CONVERSION.include?(flattened_tag)
      end

      def needs_c_to_ruby_conversion_for_functions?
        TAGS_NEEDING_C_TO_RUBY_CONVERSION.include?(flattened_tag)
      end

      def needs_ruby_to_c_conversion_for_callbacks?
        [:enum].include?(flattened_tag) ||
          needs_ruby_to_c_conversion_for_functions?
      end

      def needs_c_to_ruby_conversion_for_callbacks?
        [:callback, :enum].include?(flattened_tag) ||
          needs_c_to_ruby_conversion_for_functions?
      end

      def needs_c_to_ruby_conversion_for_closures?
        [:array, :c, :ghash, :glist, :struct, :strv].include?(flattened_tag)
      end

      def needs_ruby_to_c_conversion_for_closures?
        [:array].include?(flattened_tag)
      end

      def needs_ruby_to_c_conversion_for_properties?
        [:glist, :ghash, :strv, :callback].include?(flattened_tag)
      end

      def needs_c_to_ruby_conversion_for_properties?
        [:glist, :ghash, :callback].include?(flattened_tag)
      end

      def extra_conversion_arguments
        case flattened_tag
        when :c
          [element_type, array_fixed_size]
        when :array, :ghash, :glist, :gslist, :ptr_array, :zero_terminated
          [element_type]
        else
          []
        end
      end

      GOBJECT_VALUE_NAME = 'GObject::Value'.freeze

      def gvalue?
        argument_class_name == GOBJECT_VALUE_NAME
      end

      private

      def subtype_tag_or_class(index)
        param_type(index).tag_or_class
      end

      def dictionary_element_type
        [subtype_tag_or_class(0), subtype_tag_or_class(1)]
      end

      def enumerable_element_type
        subtype_tag_or_class 0
      end

      def subtype_ffi_type(index)
        subtype = param_type(index).to_ffi_type
        if subtype == :pointer
          # NOTE: Don't use pointer directly to appease JRuby.
          :"uint#{FFI.type_size(:pointer) * 8}"
        else
          subtype
        end
      end

      def flattened_array_type
        if zero_terminated?
          zero_terminated_array_type
        else
          array_type
        end
      end

      def zero_terminated_array_type
        case element_type
        when :utf8, :filename
          :strv
        else
          :zero_terminated
        end
      end
    end
  end
end

GObjectIntrospection::ITypeInfo.send :include, GirFFI::InfoExt::ITypeInfo
