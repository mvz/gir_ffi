module GLib
  load_class :HashTable

  class HashTable
    include Enumerable
    attr_accessor :key_type
    attr_accessor :value_type

    def each
      prc = Proc.new {|keyptr, valptr, userdata|
        key = cast_from_pointer key_type, keyptr
        val = cast_from_pointer value_type, valptr
        yield key, val
      }
      ::GLib::Lib.g_hash_table_foreach self.to_ptr, prc, nil
    end

    def to_hash
      Hash[self.to_a]
    end

    def insert key, value
      keyptr = cast_to_pointer key_type, key
      valptr = cast_to_pointer value_type, value
      ::GLib::Lib.g_hash_table_insert self.to_ptr, keyptr, valptr
    end

    def cast_to_pointer type, it
      if type == :utf8
        GirFFI::InPointer.from :utf8, it
      else
        FFI::Pointer.new(it)
      end
    end

    def cast_from_pointer type, it
      case type
      when :utf8
        GirFFI::ArgHelper.ptr_to_utf8 it
      when :gint32
        GirFFI::ArgHelper.cast_pointer_to_int32 it
      else
        it.address
      end
    end

    def self.wrap keytype, valtype, ptr
      super(ptr).tap do |it|
        break if it.nil?
        it.key_type = keytype
        it.value_type = valtype
      end
    end
  end
end
