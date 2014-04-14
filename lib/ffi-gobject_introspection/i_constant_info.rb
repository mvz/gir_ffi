module GObjectIntrospection
  # Wraps a GIConstantInfo struct; represents a constant.
  class IConstantInfo < IBaseInfo
    TYPE_TAG_TO_UNION_MEMBER = {
      gint8:   :v_int8,
      gint16:  :v_int16,
      gint32:  :v_int32,
      gint64:  :v_int64,
      guint8:  :v_uint8,
      guint16: :v_uint16,
      guint32: :v_uint32,
      guint64: :v_uint64,
      gdouble: :v_double,
      utf8:    :v_string
    }

    def value_union
      val = Lib::GIArgument.new
      Lib.g_constant_info_get_value @gobj, val
      return val
    end

    def value
      tag = constant_type.tag
      val = value_union[TYPE_TAG_TO_UNION_MEMBER[tag]]
      if tag == :utf8
        val.force_encoding("utf-8")
      else
        val
      end
    end

    def constant_type
      ITypeInfo.wrap(Lib.g_constant_info_get_type @gobj)
    end
  end
end
