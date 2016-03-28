# frozen_string_literal: true

module GirFFI
  # Module implementing the concept of ownership. Owned objects need to have
  # their memory freed or ref count lowered when they're garbage collected.
  # Note that this attribute is generally placed on the nested struct of an
  # object, and the relevant action is performed when the object's finalizer is
  # run.
  module Ownable
    attr_accessor :owned

    def owned?
      owned
    end
  end
end
