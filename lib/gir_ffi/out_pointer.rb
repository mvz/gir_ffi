require 'gir_ffi/in_out_pointer'

module GirFFI
  # The OutPointer class handles setup of pointers and their conversion to
  # ruby types for arguments with direction :out.
  class OutPointer < InOutPointer
    def self.for type
      ffi_type = type_to_ffi_type type
      ptr = AllocationHelper.safe_malloc(FFI.type_size ffi_type)
      ptr.send "put_#{ffi_type}", 0, 0
      self.new ptr, type, ffi_type
    end
  end
end
