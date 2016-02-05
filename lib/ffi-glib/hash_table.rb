# frozen_string_literal: true
require 'ffi-glib/container_class_methods'

GLib.load_class :HashTable

module GLib
  # Overrides for GHashTable, GLib's hash table implementation.
  class HashTable
    include Enumerable
    extend ContainerClassMethods

    attr_reader :key_type
    attr_reader :value_type

    def initialize(key_type, value_type)
      @key_type = key_type
      @value_type = value_type
      store_pointer Lib.g_hash_table_new(
        hash_function_for_key_type, equality_function_for_key_type)
    end

    # @api private
    def self.from_enumerable(typespec, hash)
      ghash = new(*typespec)
      hash.each do |key, val|
        ghash.insert key, val
      end
      ghash
    end

    def each
      prc = proc do |keyptr, valptr, _userdata|
        key = GirFFI::ArgHelper.cast_from_pointer key_type, keyptr
        val = GirFFI::ArgHelper.cast_from_pointer value_type, valptr
        yield key, val
      end
      callback = GLib::HFunc.from prc
      ::GLib::Lib.g_hash_table_foreach to_ptr, callback, nil
    end

    def to_hash
      Hash[to_a]
    end

    # @override
    def insert(key, value)
      keyptr = GirFFI::InPointer.from key_type, key
      valptr = GirFFI::InPointer.from value_type, value
      ::GLib::Lib.g_hash_table_insert to_ptr, keyptr, valptr
    end

    # @api private
    def reset_typespec(typespec)
      @key_type, @value_type = *typespec
      self
    end

    private

    def hash_function_for_key_type
      case @key_type
      when :utf8
        FFI::Function.new(:uint,
                          [:pointer],
                          find_support_function('g_str_hash'))
      end
    end

    def equality_function_for_key_type
      case @key_type
      when :utf8
        FFI::Function.new(:int,
                          [:pointer, :pointer],
                          find_support_function('g_str_equal'))
      end
    end

    def find_support_function(name)
      lib = ::GLib::Lib.ffi_libraries.first
      lib.find_function(name)
    end
  end
end
