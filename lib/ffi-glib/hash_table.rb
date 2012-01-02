module GLib
  load_class :HashTable

  # Overrides for GHashTable, GLib's hash table implementation.
  class HashTable
    include Enumerable
    # TODO: Restructure so these can become attr_readers.
    attr_accessor :key_type
    attr_accessor :value_type

    def each
      prc = Proc.new {|keyptr, valptr, userdata|
        key = GirFFI::ArgHelper.cast_from_pointer key_type, keyptr
        val = GirFFI::ArgHelper.cast_from_pointer value_type, valptr
        yield key, val
      }
      ::GLib::Lib.g_hash_table_foreach self.to_ptr, prc, nil
    end

    def to_hash
      Hash[self.to_a]
    end

    def insert key, value
      keyptr = GirFFI::InPointer.from key_type, key
      valptr = GirFFI::InPointer.from value_type, value
      ::GLib::Lib.g_hash_table_insert self.to_ptr, keyptr, valptr
    end

    class << self
      remove_method :new
    end

    def self.new keytype, valtype
      wrap [keytype, valtype], Lib.g_hash_table_new(
        hash_function_for(keytype), equality_function_for(keytype))
    end

    def self.wrap types, ptr
      super(ptr).tap do |it|
        return nil if it.nil?
        reset_types types, it
      end
    end

    def self.from types, it
      case it
      when nil
        nil
      when FFI::Pointer
        wrap types, it
      when self
        reset_types types, it
      else
        from_hash_like types, it
      end
    end

    def self.reset_types types, hash
      hash.key_type, hash.value_type = *types
      return hash
    end

    def self.from_hash_like types, hash
      ghash = self.new(*types)
      hash.each do |key, val|
        ghash.insert key, val
      end
      ghash
    end

    def self.hash_function_for keytype
      case keytype
      when :utf8
        FFI::Function.new(:uint, [:pointer], find_support_funtion("g_str_hash"))
      else
        nil
      end
    end

    def self.equality_function_for keytype
      case keytype
      when :utf8
        FFI::Function.new(:int, [:pointer, :pointer], find_support_funtion("g_str_equal"))
      else
        nil
      end
    end

    def self.find_support_funtion name
      lib = ::GLib::Lib.ffi_libraries.first
      lib.find_function(name)
    end
  end
end
