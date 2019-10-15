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
  end
end
