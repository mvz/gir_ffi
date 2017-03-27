# frozen_string_literal: true

GLib.load_class :DestroyNotify

module GLib
  # Overrides for DestroyNotify, the callback type for destroy notifications.
  # It should not be necessary to create objects of this class from Ruby
  # directly.
  class DestroyNotify
    def self.default
      @default ||= from proc { |user_data|
        callback_key = GirFFI::ArgHelper::OBJECT_STORE.fetch(user_data)
        drop_callback callback_key
      }
    end
  end
end
