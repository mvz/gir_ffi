module GObjectIntrospection
  # Wraps a GIConstantInfo struct; represents an constant.
  class IConstantInfo < IBaseInfo
    TYPE_TAG_TO_UNION_MEMBER = {
      :gint32 => :v_int32,
      :gdouble => :v_double,
      :utf8 => :v_string
    }

    def value_union
      val = Lib::GIArgument.new
      Lib.g_constant_info_get_value @gobj, val
      return val
    end

    def value
      tag = constant_type.tag
      val = value_union[TYPE_TAG_TO_UNION_MEMBER[tag]]
      if RUBY_VERSION >= "1.9" and tag == :utf8
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
