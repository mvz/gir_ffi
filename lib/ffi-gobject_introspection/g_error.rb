module GObjectIntrospection
  # Wraps GLib's GError struct.
  class GError
    # GLib's GError struct.
    class Struct < FFI::Struct
      layout :domain, :uint32,
        :code, :int,
        :message, :string
    end

    def initialize ptr
      @struct = self.class::Struct.new(ptr)
    end

    def message
      @struct[:message]
    end
  end
end
