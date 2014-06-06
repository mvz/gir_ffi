# Class to represent the info for the receiver argument of a callback or signal
# handler. Implements the necessary parts of IArgumentInfo's interface.
class GirFFI::ReceiverArgumentInfo
  attr_reader :argument_type

  def initialize type
    @argument_type = type
  end

  def direction
    :in
  end

  def name
    "_instance"
  end
end
