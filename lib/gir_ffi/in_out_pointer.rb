module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout and :out.
  #
  # TODO: This has now become a more general extende pointer class and should be renamed.
  class InOutPointer < FFI::Pointer
    attr_reader :value_type

    def initialize type, ptr = nil
      @value_type = type

      ptr ||= AllocationHelper.safe_malloc(value_type_size)
      super ptr
    end

    private :initialize

    # TODO: Rename to get_value
    def to_value
      case value_ffi_type
      when Class
        value_ffi_type.get_value_from_pointer(self)
      when Symbol
        self.send("get_#{value_ffi_type}", 0)
      when FFI::Enum
        self.get_int32 0
      else
        raise NotImplementedError
      end
    end

    # Convert more fully to a ruby value than #to_value
    def to_ruby_value
      bare_value = to_value
      case value_type
      when :utf8
        GirFFI::ArgHelper.ptr_to_utf8 bare_value
      when Symbol
        bare_value
      when Array
        value_type[1].wrap bare_value
      else
        value_type.wrap bare_value
      end
    end

    def set_value value
      case value_ffi_type
      when Class
        value_ffi_type.copy_value_to_pointer(value, self)
      when Symbol
        self.send "put_#{value_ffi_type}", 0, value
      else
        raise NotImplementedError
      end
    end

    def clear
      set_value nil_value
    end

    def self.for type
      self.new(type).tap {|ptr| ptr.clear}
    end

    def self.from type, value
      self.new(type).tap {|ptr| ptr.set_value value}
    end

    private

    def value_ffi_type
      @value_ffi_type ||= TypeMap.type_specification_to_ffitype value_type
    end

    def value_type_size
      @value_type_size ||= FFI.type_size value_ffi_type
    end

    def nil_value
      value_ffi_type == :pointer ? nil : 0
    end
  end
end
