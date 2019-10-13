# frozen_string_literal: true

module GirFFI
  # Class to represent the info for the receiver argument of a callback or
  # signal handler. Implements the necessary parts of IArgInfo's
  # interface.
  class ReceiverArgumentInfo
    attr_reader :argument_type

    def initialize(type)
      @argument_type = type
    end

    def direction
      :in
    end

    # Assume we don't need to increase the refcount for the receiver argument.
    def ownership_transfer
      :everything
    end

    def name
      "_instance"
    end
  end
end
