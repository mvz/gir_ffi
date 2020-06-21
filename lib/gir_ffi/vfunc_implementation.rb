# frozen_string_literal: true

module GirFFI
  # Simple wrapper class to represent the implementation of a VFunc.
  class VFuncImplementation
    attr_reader :name, :implementation

    def initialize(name, implementation)
      implementation ||= ->(obj, *args) { obj.public_send name, *args }
      @name = name
      @implementation = implementation
    end
  end
end
