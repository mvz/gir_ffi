require 'ffi-glib/container_class_methods'

module GLib
  load_class :HashTable

  # Overrides for GHashTable, GLib's hash table implementation.
  class HashTable
    include Enumerable
    extend ContainerClassMethods

    attr_reader :key_type
    attr_reader :value_type

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

    def reset_typespec typespec
      @key_type, @value_type = *typespec
      self
    end

    def self.from_enumerable typespec, hash
      ghash = self.new(*typespec)
      hash.each do |key, val|
        ghash.insert key, val
      end
      ghash
    end

    def self.hash_function_for keytype
      case keytype
      when :utf8
        FFI::Function.new(:uint,
                          [:pointer],
                          find_support_function("g_str_hash"))
      else
        nil
      end
    end

    def self.equality_function_for keytype
      case keytype
      when :utf8
        FFI::Function.new(:int,
                          [:pointer, :pointer],
                          find_support_function("g_str_equal"))
      else
        nil
      end
    end

    def self.find_support_function name
      lib = ::GLib::Lib.ffi_libraries.first
      lib.find_function(name)
    end
  end
end
