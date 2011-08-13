module GirFFI
  # The OutPointer class handles setup of pointers and their conversion to
  # ruby types for arguments with direction :out.
  class OutPointer < FFI::Pointer
    def self.for type
      value = case type
              when :gboolean : false
              when :utf8 : nil
              else 0
              end
      ptr = InOutPointer.from type, value
      self.new ptr
    end
  end
end
