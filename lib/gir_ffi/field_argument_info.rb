# frozen_string_literal: true

module GirFFI
  # Class to represent argument info for the argument of a setter method.
  # Implements the necessary parts of IArgInfo's interface.
  # TODO: Rename and add direction argument or subclass
  class FieldArgumentInfo
    attr_reader :name, :argument_type

    def initialize(name, type)
      @name = name
      @argument_type = type
    end

    def direction
      :in
    end

    def ownership_transfer
      :everything
    end

    def skip?
      false
    end
  end
end
