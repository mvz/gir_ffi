module GirFFI
  # The InOutPointer class handles conversion between ruby types and
  # pointers for arguments with direction :inout and :out.
  class InOutPointer < FFI::Pointer
    attr_reader :value_type, :sub_type

    def initialize value, type, sub_type=nil
      @ffi_type = TypeMap.map_basic_type_or_string type
      @value_type = type
      @sub_type = sub_type

      value = adjust_value_in value

      ptr = AllocationHelper.safe_malloc(FFI.type_size @ffi_type)
      ptr.send "put_#{@ffi_type}", 0, value

      super ptr
    end

    private :initialize

    def to_value
      value = self.send "get_#{@ffi_type}", 0
      adjust_value_out value
    end

    def to_sized_array_value size
      # FIXME: Simulated Polymorphism.
      raise "Not allowed" if @ffi_type != :pointer or @sub_type.nil?
      block = self.read_pointer
      return nil if block.null?
      ArgHelper.ptr_to_typed_array @sub_type, block, size
    end

    def self.for type, sub_type=nil
      if Array === type
        return self.new nil, *type
      end
      self.new nil, type, sub_type
    end

    def self.from type, value, sub_type=nil
      if Array === type
        _, sub_t = *type
        # TODO: Take array type into account (zero-terminated or not)
        return self.from_array sub_t, value
      end
      self.new value, type, sub_type
    end

    def self.from_array type, array
      ptr = InPointer.from_array(type, array)
      self.from :pointer, ptr, type
    end

    private

    def adjust_value_in value
      case @value_type
      when :gboolean
        (value ? 1 : 0)
      when :utf8
        InPointer.from :utf8, value
      else
        value || nil_value
      end
    end

    def nil_value
      @ffi_type == :pointer ? nil : 0
    end

    def adjust_value_out value
      case @value_type
      when :gboolean
        (value != 0)
      else
        value
      end
    end

  end
end

