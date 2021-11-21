# frozen_string_literal: true

GLib.load_class :DestroyNotify

module GLib
  # Overrides for DestroyNotify, the callback type for destroy notifications.
  # It should not be necessary to create objects of this class from Ruby
  # directly.
  class DestroyNotify
    # Return the default DestroyNotify object used when calling functions that
    # take a DestroyNotify argument.
    #
    # GirFFI uses a singleton object here to ensure it will always exist when
    # called from the C side.
    #
    # This assumes ClosureToPointerConvertor creates code store the callbacak
    # to be destroyed using ArgHelper.store.
    def self.default
      @default ||= from proc { |user_data|
        callback = GirFFI::ArgHelper::OBJECT_STORE.fetch(user_data)
        drop_callback callback
      }
    end
  end
end
