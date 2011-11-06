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
      keyptr = GirFFI::ArgHelper.cast_to_pointer key_type, key
      valptr = GirFFI::ArgHelper.cast_to_pointer value_type, value
      ::GLib::Lib.g_hash_table_insert self.to_ptr, keyptr, valptr
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
