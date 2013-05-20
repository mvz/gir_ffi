module GirFFI
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
