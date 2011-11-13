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
        wrap(keytype, valtype, Lib.g_hash_table_new(hash_fn, eq_fn))
      end

      def wrap keytype, valtype, ptr
        super(ptr).tap do |it|
          break if it.nil?
          it.key_type = keytype
          it.value_type = valtype
        end
      end
    end
  end
end
