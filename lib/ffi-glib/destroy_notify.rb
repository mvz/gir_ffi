GLib.load_class :DestroyNotify

module GLib
  # Overrides for DestroyNotify, the callback type for destroy notifications.
  # It should not be necessary to create objects of this class from Ruby
  # directly.
  class DestroyNotify
    def self.default
      @default ||= from proc { |id| drop_callback id }
    end
  end
end
