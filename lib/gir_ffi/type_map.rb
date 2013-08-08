module GirFFI
  module TypeMap
    sz = FFI.type_size(:size_t) * 8
    gtype_type = "uint#{sz}".to_sym

    TAG_TYPE_MAP = {
      :enum => :int32,
      :flags => :int32,
      :ghash => :pointer,
      :glist => :pointer,
      :gslist => :pointer,
      :strv => :pointer,
      :c => :pointer,
      :object => :pointer,
      :struct => :pointer,
      :error => :pointer,
      :ptr_array => :pointer,
      :array => :pointer,
      :utf8 => :pointer,
      :GType => gtype_type,
      :gboolean => GLib::Boolean,
      :gunichar => :uint32,
      :gint8 => :int8,
      :guint8 => :uint8,
      :gint16 => :int16,
      :guint16 => :uint16,
      :gint => :int,
      :gint32 => :int32,
      :guint32 => :uint32,
      :gint64 => :int64,
      :guint64 => :uint64,
      :gfloat => :float,
      :gdouble => :double,
      :void => :void
    }

    def self.map_basic_type type
      sym = type.to_sym
      TAG_TYPE_MAP[sym] || sym
    end

    def self.type_specification_to_ffitype type
      case type
      when Module
        type.to_ffitype
      when Array
        type[0]
      else
        map_basic_type(type)
      end
    end
  end
end
