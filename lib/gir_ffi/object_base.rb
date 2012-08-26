module GirFFI
  # Base class for all generated classes of type :object.
  class ObjectBase < ClassBase
    # Method for wrapping a pointer retrieved from a constructor method. Here,
    # it is simply defined as a wrapper around wrap, but, e.g., InitiallyUnowned
    # overrides it to sink the floating object.
    def self.constructor_wrap ptr
      wrap ptr
    end
  end
end

