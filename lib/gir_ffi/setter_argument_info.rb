module GirFFI
  # Class to represent argument info for the argument of a setter method.
  # Implements the necessary parts of IArgumentInfo's interface.
  class SetterArgumentInfo
    attr_reader :name, :argument_type

    def initialize name, type
      @name = name
      @argument_type = type
    end

    def direction
      :in
    end

    def skip?
      false
    end
  end
end
