module GirFFI
  module TypeMap
    sz = FFI.type_size(:size_t) * 8
    gtype_type = "uint#{sz}".to_sym

    TAG_TYPE_MAP = {
      :enum => :int32,
      :flags => :int32,
      :strv => :pointer,
      :object => :pointer,
      :struct => :pointer,
      :GType => gtype_type,
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

    # FIXME: Make name more descriptive.
    def self.map_basic_type_or_string type
      case type
      when :gboolean
        :int32
      when :utf8
        :pointer
      else
        map_basic_type(type)
      end
    end
  end
end
