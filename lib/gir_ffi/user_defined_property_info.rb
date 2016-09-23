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

    def ffi_type
      @param_spec.ffi_type
    end

    def type_tag
      @param_spec.type_tag
    end

    def pointer_type?
      @param_spec.pointer_type?
    end

    def flags
      @param_spec.flags
    end
  end
end
