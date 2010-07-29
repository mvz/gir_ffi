module GirFFI
  # Wraps GObject's GError struct.
  class GError < FFI::Struct
    layout :domain, :uint32,
      :code, :int,
      :message, :string
  end
end
