module GirFFI
  # The InPointer class handles conversion from ruby types to pointers for
  # arguments with direction :in. This is used for arguments that are
  # arrays, strings, or interfaces.
  class InPointer < FFI::Pointer
    def self.from_array type, ary
      return nil if ary.nil?
      return self.from_utf8_array ary if type == :utf8
      return self.from_interface_pointer_array ary if type == :interface_pointer

      ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type
      block = ArgHelper.allocate_array_of_type ffi_type, ary.length
      block.send "put_array_of_#{ffi_type}", 0, ary

      self.new block
    end

    def self.from type, val
      self.new ArgHelper.utf8_to_inptr(val)
    end

    def self.from_utf8_array ary
      return nil if ary.nil?
      ptr_ary = ary.map {|str| ArgHelper.utf8_to_inptr str}
      ptr_ary << nil
      self.from_array :pointer, ptr_ary
    end

    def self.from_interface_pointer_array ary
      return nil if ary.nil?
      ptr_ary = ary.map {|ifc| ifc.to_ptr}
      ptr_ary << nil
      self.from_array :pointer, ptr_ary
    end
  end
end
