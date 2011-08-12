module GirFFI
  class InPointer < FFI::Pointer
    def self.from_array type, array
      return nil if array.nil?
      self.new ArgHelper.typed_array_to_inptr(type, array)
    end
  end
end
