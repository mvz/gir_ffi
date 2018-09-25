# frozen_string_literal: true

GObject.load_class :ParamSpec

module GObject
  # Overrides for GParamSpec, GObject's base class for parameter specifications.
  class ParamSpec
    VALUE_TYPE_OFFSET = Struct.offset_of :value_type
    FLAGS_OFFSET = Struct.offset_of :flags

    def ref
      Lib.g_param_spec_ref self
      self
    end

    def accessor_name
      get_name.tr('-', '_')
    end

    def value_type
      to_ptr.get_gtype(VALUE_TYPE_OFFSET)
    end

    def flags
      GObject::ParamFlags.get_value_from_pointer(to_ptr, FLAGS_OFFSET)
    end
  end
end
