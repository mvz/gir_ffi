module GirFFI
  # Represents a return value with the same interface as IArgumentInfo
  class ReturnValueInfo
    attr_reader :argument_type

    def initialize type, skip = false
      @argument_type = type
      @skip = skip
    end

    def skip?
      @skip
    end

    def direction
      :return
    end

    def name
      nil
    end
  end
end
