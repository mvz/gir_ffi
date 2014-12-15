module GirFFI
  # Represents a return value with the same interface as IArgumentInfo
  class ReturnValueInfo
    attr_reader :argument_type
    attr_reader :ownership_transfer

    def initialize type, ownership_transfer, skip
      @argument_type = type
      @ownership_transfer = ownership_transfer
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
