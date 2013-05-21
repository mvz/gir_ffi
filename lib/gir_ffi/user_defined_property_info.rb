module GirFFI
  # Represents a property of a user defined type, conforming, as needed, to the
  # interface of GObjectIntrospection::IPropertyInfo.
  class UserDefinedPropertyInfo
    def initialize param_spec
      @param_spec = param_spec
    end

    attr_reader :param_spec

    def name
      @param_spec.get_name
    end
  end
end
