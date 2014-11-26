module GirFFI
  # Class to represent the info for the user data argument of a signal handler.
  # Implements the necessary parts of IArgumentInfo's interface.
  class UserDataArgumentInfo
    attr_reader :argument_type

    def initialize type
      @argument_type = type
    end

    def direction
      :in
    end

    def skip?
      false
    end

    def name
      '_user_data'
    end
  end
end
