module GirFFI
  class GError < FFI::Struct
    layout :domain, :uint32,
      :code, :int,
      :message, :string
  end
end
