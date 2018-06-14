# frozen_string_literal: true

module GLib
  # Represents a null-terminated array of strings. GLib uses this construction,
  # but does not provide any actual functions for this class.
  #
  # The implementation is mainly inherited from GObjectIntrospection::Strv.
  class Strv < GObjectIntrospection::Strv
    def ==(other)
      to_a == other.to_a
    end

    def self.from(obj)
      case obj
      when nil
        nil
      when FFI::Pointer
        wrap obj
      when self
        obj
      else
        from_enumerable obj
      end
    end

    def self.from_enumerable(enum)
      wrap GirFFI::InPointer.from_array :utf8, enum
    end
  end
end
