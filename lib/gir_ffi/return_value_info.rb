# frozen_string_literal: true

module GirFFI
  # Represents a return value with the same interface as IArgInfo
  class ReturnValueInfo
    attr_reader :argument_type, :ownership_transfer

    def initialize(type, ownership_transfer, skip)
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
