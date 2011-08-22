require 'gir_ffi/allocation_helper'
require 'gir_ffi/callback_helper'
require 'gir_ffi/builder'

module GirFFI
  module ArgHelper
    POINTER_SIZE = FFI.type_size(:pointer)

    SIMPLE_G_TYPES = [
      :gint8, :gint16, :gint, :gint32, :gint64,
      :guint8, :guint16, :guint32, :guint64,
      :gfloat, :gdouble]

    # FIXME: Hideous.
    def self.object_to_inptr obj
      return obj.to_ptr if obj.respond_to? :to_ptr
      return nil if obj.nil?
      return obj if obj.is_a? FFI::Pointer
      FFI::Pointer.new(obj.object_id)
    end

    # Converts an outptr to a string array.
    def self.outptr_to_utf8_array ptr, size
      block = ptr.read_pointer
      return nil if block.null?
      ptr_to_utf8_array block, size
    end

    # Converts an outptr to an array of int.
    def self.outptr_to_int32_array ptr, size
      block = ptr.read_pointer
      return nil if block.null?
      ptr_to_gint32_array block, size
    end

    # Converts an outptr to an array of the given class.
    def self.outptr_to_interface_array klass, ptr, size
      block = ptr.read_pointer
      return nil if block.null?
      ptr_to_interface_array klass, block, size
    end

    class << self
      alias outptr_to_int_array outptr_to_int32_array
      alias outptr_to_gint32_array outptr_to_int32_array
    end

    def self.ptr_to_typed_array type, ptr, size
      if type == :utf8
        ptr_to_utf8_array ptr, size
      else
        ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type
        ptr.send "get_array_of_#{ffi_type}", 0, size
      end
    end

    def self.setup_ptr_to_type_array_handler_for *types
      types.flatten.each do |type|
        ffi_type = GirFFI::Builder::TAG_TYPE_MAP[type] || type
        defn =
          "def self.ptr_to_#{type}_array ptr, size
            ptr.get_array_of_#{ffi_type}(0, size)
          end"
        eval defn
      end
    end

    setup_ptr_to_type_array_handler_for SIMPLE_G_TYPES

    def self.ptr_to_utf8_array ptr, size
      ptrs = ptr.read_array_of_pointer(size)

      ptrs.map { |ptr| ptr_to_utf8 ptr }
    end

    def self.ptr_to_interface_array klass, ptr, size
      struct_size = klass.ffi_structure.size
      size.times.map do |idx|
        klass.wrap(ptr + struct_size * idx)
      end
    end

    if RUBY_VERSION < "1.9"
      def self.ptr_to_utf8 ptr
        ptr.null? ? nil : ptr.read_string
      end
    else
      def self.ptr_to_utf8 ptr
        ptr.null? ? nil : ptr.read_string.force_encoding("utf-8")
      end
    end

    def self.ptr_to_utf8_length ptr, len
      ptr.null? ? nil : ptr.read_string(len)
    end

    # Set up gtype handlers depending on type size.
    class << self
      sz = FFI.type_size(:size_t) * 8
      type = "guint#{sz}"
      alias_method :ptr_to_gtype_array, "ptr_to_#{type}_array"
    end

    def self.outptr_strv_to_utf8_array ptr
      strv_to_utf8_array ptr.read_pointer
    end

    def self.strv_to_utf8_array strv
      return [] if strv.null?
      arr, offset = [], 0
      until (ptr = strv.get_pointer offset).null? do
        arr << ptr.read_string
        offset += POINTER_SIZE
      end
      return arr
    end

    def self.utf8_array_to_glist arr
      return nil if arr.nil?
      arr.inject(GLib.list_new :utf8) { |lst, str|
        GLib.list_append lst, InPointer.from(:utf8, str) }
    end

    def self.gint32_array_to_glist arr
      return nil if arr.nil?
      arr.inject(GLib.list_new :gint32) { |lst, int|
        GLib.list_append lst, cast_int32_to_pointer(int) }
    end

    def self.utf8_array_to_gslist arr
      return nil if arr.nil?
      arr.reverse.inject(GLib.slist_new :utf8) { |lst, str|
        GLib.slist_prepend lst, InPointer.from(:utf8, str) }
    end

    def self.gint32_array_to_gslist arr
      return nil if arr.nil?
      arr.reverse.inject(GLib.slist_new :gint32) { |lst, int|
        GLib.slist_prepend lst, cast_int32_to_pointer(int) }
    end

    def self.hash_to_ghash keytype, valtype, hash
      return nil if hash.nil?
      ghash = GLib.hash_table_new keytype, valtype
      hash.each do |key, val|
        ghash.insert key, val
      end
      ghash
    end

    def self.void_array_to_gslist ary
      return nil if ary.nil?
      return ary if ary.is_a? GLib::SList
      raise NotImplementedError
    end

    def self.check_error errpp
      errp = errpp.read_pointer
      raise GError.new(errp)[:message] unless errp.null?
    end

    def self.check_fixed_array_size size, arr, name
      unless arr.size == size
	raise ArgumentError, "#{name} should have size #{size}"
      end
    end

    def self.allocate_array_of_type type, length
      AllocationHelper.safe_malloc FFI.type_size(type) * length
    end

    # FIXME: Quasi-circular dependency on generated module
    def self.object_pointer_to_object optr
      return nil if optr.null?
      gtype = ::GObject.type_from_instance_pointer optr
      klass = GirFFI::Builder.build_by_gtype gtype
      klass.wrap optr
    end

    def self.cast_from_pointer type, it
      case type
      when :utf8, :filename
        ptr_to_utf8 it
      when :gint32
        cast_pointer_to_int32 it
      else
        it.address
      end
    end

    def self.cast_uint32_to_int32 val
      if val >= 0x80000000
        -(0x100000000-val)
      else
        val
      end
    end

    def self.cast_pointer_to_int32 ptr
      cast_uint32_to_int32(ptr.address & 0xffffffff)
    end

    def self.cast_int32_to_pointer int
      FFI::Pointer.new(int)
    end
  end
end
