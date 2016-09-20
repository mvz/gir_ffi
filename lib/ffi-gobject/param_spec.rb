# frozen_string_literal: true
GObject.load_class :ParamSpec

module GObject
  # Overrides for GParamSpec, GObject's base class for parameter specifications.
  class ParamSpec
    def ref
      Lib.g_param_spec_ref self
      self
    end

    def accessor_name
      get_name.tr('-', '_')
    end

    def pointer_type?
      case value_type
      when TYPE_INT
        false
      when TYPE_STRING
        true
      end
    end

    def type_tag
      case value_type
      when TYPE_INT
        :gint
      when TYPE_STRING
        :utf8
      when TYPE_LONG
        :glong
      end
    end

    def ffi_type
      GirFFI::TypeMap.map_basic_type(type_tag)
    end
  end
end
