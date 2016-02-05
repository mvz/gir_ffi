# frozen_string_literal: true
module GirFFI
  # Class to represent the info for the receiver argument of a callback or
  # signal handler. Implements the necessary parts of IArgumentInfo's
  # interface.
  class ReceiverArgumentInfo
    attr_reader :argument_type

    def initialize(type)
      @argument_type = type
    end

    def direction
      :in
    end

    def ownership_transfer
      # FIXME: Make an informed choice for this.
      :everything
    end

    def name
      '_instance'
    end
  end
end
