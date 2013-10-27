module GirFFI
  # Represents a return value with the same interface as IArgumentInfo
  class ReturnValueInfo
    attr_reader :argument_type

    def initialize type
      @argument_type = type
    end
  end
end
