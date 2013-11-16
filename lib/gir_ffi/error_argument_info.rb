module GirFFI
  # Represents an error argument with the same interface as IArgumentInfo
  class ErrorArgumentInfo
    def skip?
      false
    end

    def direction
      :error
    end

    def argument_type
      nil
    end

    def name
      nil
    end
  end
end

