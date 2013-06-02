module GirFFI
  # TODO: Turn module into a class, use instance methods.
  module CallbackHelper
    CALLBACKS = []

    def self.store_callback prc
      CALLBACKS << prc
    end
  end
end

