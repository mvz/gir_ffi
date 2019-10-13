# frozen_string_literal: true

require "gir_ffi/boolean"
require "gir_ffi/sized_array"

module GirFFI
  # Maps GObject type tags and type specification to types FFI can handle.
  module TypeMap
    sz = FFI.type_size(:size_t) * 8
    gsize_type = "uint#{sz}".to_sym

    TAG_TYPE_MAP = {
      enum:      :int32,
      flags:     :int32,
      ghash:     :pointer,
      glist:     :pointer,
      gslist:    :pointer,
      strv:      :pointer,
      interface: :pointer,
      error:     :pointer,
      ptr_array: :pointer,
      array:     :pointer,
      c:         GirFFI::SizedArray,
      utf8:      :pointer,
      GType:     gsize_type,
      gboolean:  GirFFI::Boolean,
      gunichar:  :uint32,
      gint8:     :int8,
      guint8:    :uint8,
      gint16:    :int16,
      guint16:   :uint16,
      gint:      :int,
      guint:     :uint,
      gint32:    :int32,
      guint32:   :uint32,
      gint64:    :int64,
      guint64:   :uint64,
      glong:     :long,
      gulong:    :ulong,
      gsize:     gsize_type,
      gfloat:    :float,
      gdouble:   :double,
      void:      :void
    }.freeze

    def self.map_basic_type(type)
      sym = type.to_sym
      TAG_TYPE_MAP[sym] || sym
    end

    def self.type_specification_to_ffi_type(type)
      case type
      when Module
        type.to_ffi_type
      when Array
        type[0]
      else
        map_basic_type(type)
      end
    end

    FLATTENED_TAG_TO_GTYPE_MAP = {
      [:array, true]     => GObject::TYPE_ARRAY,
      [:c, true]         => GObject::TYPE_POINTER,
      [:gboolean, false] => GObject::TYPE_BOOLEAN,
      [:ghash, true]     => GObject::TYPE_HASH_TABLE,
      [:glist, true]     => GObject::TYPE_POINTER,
      [:gint32, false]   => GObject::TYPE_INT,
      [:gint64, false]   => GObject::TYPE_INT64,
      [:guint64, false]  => GObject::TYPE_UINT64,
      [:strv, true]      => GObject::TYPE_STRV,
      [:utf8, true]      => GObject::TYPE_STRING,
      [:void, true]      => GObject::TYPE_POINTER,
      [:void, false]     => GObject::TYPE_NONE
    }.freeze

    def self.type_info_to_gtype(type_info)
      return type_info.interface.gtype if type_info.tag == :interface

      FLATTENED_TAG_TO_GTYPE_MAP.fetch [type_info.flattened_tag, type_info.pointer?]
    end
  end
end
