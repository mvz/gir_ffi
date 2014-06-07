module GLib
  load_class :IConv

  # Overrides for IConv
  class IConv
    def self.open to_codeset, from_codeset
      to_ptr = GirFFI::InPointer.from(:utf8, to_codeset)
      from_ptr = GirFFI::InPointer.from(:utf8, from_codeset)
      result_ptr = Lib.g_iconv_open(to_ptr, from_ptr)
      wrap(result_ptr)
    end
  end
end

