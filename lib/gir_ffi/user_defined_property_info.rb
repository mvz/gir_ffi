# frozen_string_literal: true
module GirFFI
  # Represents a property of a user defined type, conforming, as needed, to the
  # interface of GObjectIntrospection::IPropertyInfo.
  class UserDefinedPropertyInfo
    def initialize(param_spec)
      @param_spec = param_spec
    end

    attr_reader :param_spec

    def name
      @param_spec.get_name
    end

    def accessor_name
      @param_spec.accessor_name
    end

    def writable?
      @param_spec.flags[:writable]
    end

    def value_type
      @param_spec.value_type
    end

    def pointer_type?
      case value_type
      when GObject::TYPE_INT
        false
      else
        true
      end
    end

    G_TYPE_MAP = {
      GObject::TYPE_INT => :gint,
      GObject::TYPE_STRING => :utf8,
      GObject::TYPE_LONG => :glong,
      GObject::TYPE_BOXED => :interface
    }.freeze

    def type_tag
      fundamental_type = GObject.type_fundamental value_type
      G_TYPE_MAP.fetch(fundamental_type)
    end

    def ffi_type
      GirFFI::TypeMap.map_basic_type(type_tag)
    end
  end
end
