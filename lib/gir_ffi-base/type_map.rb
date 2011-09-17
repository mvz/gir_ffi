module GirFFI
  module TypeMap
    sz = FFI.type_size(:size_t) * 8
    gtype_type = "uint#{sz}".to_sym

    TAG_TYPE_MAP = {
      :GType => :size_t,
      :gtype => gtype_type,
      :gboolean => :bool,
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
      TAG_TYPE_MAP[type] || type
    end
  end
end
