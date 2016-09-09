# frozen_string_literal: true
module GObjectIntrospection
  # Wraps a GIConstantInfo struct; represents a constant.
  class IConstantInfo < IBaseInfo
    TYPE_TAG_TO_UNION_MEMBER = {
      gboolean: :v_boolean,
      gint8:    :v_int8,
      gint16:   :v_int16,
      gint32:   :v_int32,
      gint64:   :v_int64,
      guint8:   :v_uint8,
      guint16:  :v_uint16,
      guint32:  :v_uint32,
      guint64:  :v_uint64,
      gdouble:  :v_double,
      utf8:     :v_string
    }.freeze

    def value
      case type_tag
      when :utf8
        raw_value.force_encoding('utf-8')
      when :gboolean
        !!raw_value.nonzero?
      else
        raw_value
      end
    end

    def constant_type
      ITypeInfo.wrap Lib.g_constant_info_get_type(@gobj)
    end

    private

    def type_tag
      @type_tag ||= constant_type.tag
    end

    def raw_value
      value_union = Lib::GIArgument.new
      Lib.g_constant_info_get_value @gobj, value_union
      value_union[union_member_key]
    end

    def union_member_key
      TYPE_TAG_TO_UNION_MEMBER[type_tag]
    end
  end
end
