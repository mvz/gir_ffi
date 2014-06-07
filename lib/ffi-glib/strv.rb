module GLib
  # Extra methods for GLib::Strv. The bulk is defined in `gir_ffi-base/glib/strv.rb`
  class Strv
    def == other
      self.to_a == other.to_a
    end

    def self.from it
      case it
      when nil
        nil
      when FFI::Pointer
        wrap it
      when self
        it
      else
        from_enumerable it
      end
    end

    def self.from_enumerable enum
      self.wrap GirFFI::InPointer.from_array :utf8, enum
    end
  end
end
