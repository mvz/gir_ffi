module GirFFI
  module Overrides
    module GLib
      def self.included base
	base.extend ClassMethods
        attach_non_introspectable_functions(base)
      end

      def self.attach_non_introspectable_functions base
        base::Lib.attach_function :g_slist_prepend, [:pointer, :pointer],
          :pointer

        base::Lib.attach_function :g_list_append, [:pointer, :pointer],
          :pointer

        base::Lib.attach_function :g_hash_table_foreach,
          [:pointer, base::HFunc, :pointer], :void
        base::Lib.attach_function :g_hash_table_new,
          [base::HashFunc, base::EqualFunc], :pointer
        base::Lib.attach_function :g_hash_table_insert,
          [:pointer, :pointer, :pointer], :void

        base::Lib.attach_function :g_byte_array_new, [], :pointer
        base::Lib.attach_function :g_byte_array_append,
          [:pointer, :pointer, :uint], :pointer

        base::Lib.attach_function :g_array_new, [:int, :int, :uint], :pointer
        base::Lib.attach_function :g_array_append_vals,
          [:pointer, :pointer, :uint], :pointer

        base::Lib.attach_function :g_main_loop_new,
          [:pointer, :bool], :pointer
      end

      module ClassMethods
        # FIXME: Turn into real constructor
        def slist_new elmttype
          ::GLib::List._real_new(FFI::Pointer.new(0)).tap {|it|
            it.element_type = elmttype}
        end

        # FIXME: Turn into instance method; Use element type.
        def slist_prepend slist, data
          ::GLib::SList.wrap(slist.element_type, ::GLib::Lib.g_slist_prepend(slist, data))
        end

        # FIXME: Turn into real constructor
        def list_new elmttype
          ::GLib::List._real_new(FFI::Pointer.new(0)).tap {|it|
            it.element_type = elmttype}
        end

        # FIXME: Turn into instance method; Use element type.
        def list_append list, data
          ::GLib::List.wrap(list.element_type, ::GLib::Lib.g_list_append(list, data))
        end

        # FIXME: Turn into real constructor
        def hash_table_new keytype, valtype
          hash_fn, eq_fn = case keytype
                           when :utf8
                             lib = ::GLib::Lib.ffi_libraries.first
                             [ FFI::Function.new(:uint, [:pointer], lib.find_function("g_str_hash")),
                               FFI::Function.new(:int, [:pointer, :pointer], lib.find_function("g_str_equal"))]
                           else
                             [nil, nil]
                           end

          ::GLib::HashTable.wrap(keytype, valtype, ::GLib::Lib.g_hash_table_new(hash_fn, eq_fn))
        end

        # FIXME: Turn into real constructor
        def byte_array_new
          ::GLib::ByteArray.wrap(::GLib::Lib.g_byte_array_new)
        end

        # FIXME: Turn into instance method
        def byte_array_append arr, data
          bytes = GirFFI::InPointer.from :utf8, data
          len = data.bytesize
          ::GLib::ByteArray.wrap(::GLib::Lib.g_byte_array_append arr.to_ptr, bytes, len)
        end

        # FIXME: Turn into real constructor
        def array_new type
          ffi_type = type == :utf8 ? :pointer : type
          arr = ::GLib::Array.wrap(
            ::GLib::Lib.g_array_new(0, 0, FFI.type_size(ffi_type)))
          arr.element_type = type
          arr
        end

        # FIXME: Turn into instance method
        def array_append_vals arr, data
          bytes = GirFFI::InPointer.from_array arr.element_type, data
          len = data.length
          res = ::GLib::Array.wrap(
            ::GLib::Lib.g_array_append_vals(arr.to_ptr, bytes, len))
          res.element_type = arr.element_type
          res
        end

        # FIXME: Turn into real constructor?
        def main_loop_new context, is_running
          ::GLib::MainLoop.wrap(::GLib::Lib.g_main_loop_new context, is_running)
        end
      end
    end
  end
end

