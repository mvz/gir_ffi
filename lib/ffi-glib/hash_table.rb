module GLib
  load_class :HashTable

  # Overrides for GHashTable, GLib's hash table implementation.
  class HashTable
    include Enumerable
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
      undef :new
      def new  keytype, valtype
        hash_fn, eq_fn = case keytype
                         when :utf8
                           lib = ::GLib::Lib.ffi_libraries.first
                           [ FFI::Function.new(:uint, [:pointer], lib.find_function("g_str_hash")),
                             FFI::Function.new(:int, [:pointer, :pointer], lib.find_function("g_str_equal"))]
                         else
                           [nil, nil]
                         end
        wrap [keytype, valtype], Lib.g_hash_table_new(hash_fn, eq_fn)
      end

      def wrap types, ptr
        keytype, valtype = *types
        return nil if ptr.nil?
        if ptr.is_a? FFI::Pointer
          super(ptr).tap do |it|
            return nil if it.nil?
            it.key_type = keytype
            it.value_type = valtype
          end
        else
          self.from_hash types, ptr
        end
      end

      def from_hash types, hash
        keytype, valtype = *types
        return nil if hash.nil?
        if hash.is_a? self
          hash.key_type = keytype
          hash.value_type = valtype
          return hash
        end
        ghash = self.new keytype, valtype
        hash.each do |key, val|
          ghash.insert key, val
        end
        ghash
      end
    end
  end
end
