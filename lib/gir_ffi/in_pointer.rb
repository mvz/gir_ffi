module GirFFI
  # The InPointer class handles conversion from ruby types to pointers for
  # arguments with direction :in. This is used for arguments that are
  # arrays, strings, or interfaces.
  class InPointer < FFI::Pointer
    def self.from_array type, array
      return nil if array.nil?
      self.new ArgHelper.typed_array_to_inptr(type, array)
    end
  end
end
