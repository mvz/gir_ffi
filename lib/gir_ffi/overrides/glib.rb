module GirFFI
  module Overrides
    module GLib
      def self.included base
	base.extend ClassMethods
        extend_classes(base)
        attach_non_introspectable_functions(base)
      end

      def self.extend_classes base
        base::SList.class_eval {
          attr_accessor :element_type
          include ListInstanceMethods
          extend ListClassMethods
          include Enumerable
        }
        base::List.class_eval {
          attr_accessor :element_type
          include ListInstanceMethods
          extend ListClassMethods
          include Enumerable
        }
        base::HashTable.class_eval {
          attr_accessor :key_type
          attr_accessor :value_type
          include HashTableInstanceMethods
          extend HashTableClassMethods
          include Enumerable
        }
        base::ByteArray.class_eval {
          include ByteArrayInstanceMethods
        }
        base::Array.class_eval {
          attr_accessor :element_type
          include ArrayInstanceMethods
        }
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
                             [::GLib::Lib.ffi_libraries.first.find_function("g_str_equal"),
                               ::GLib::Lib.ffi_libraries.first.find_function("g_str_equal")]
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
          bytes = GirFFI::ArgHelper.utf8_to_inptr data
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
          bytes = GirFFI::ArgHelper.typed_array_to_inptr arr.element_type, data
          len = data.length
          res = ::GLib::Array.wrap(
            ::GLib::Lib.g_array_append_vals(arr.to_ptr, bytes, len))
          res.element_type = arr.element_type
          res
        end

      end

      module ListInstanceMethods
        def each
          list = self
          rval = nil
          until list.nil?
            rval = yield GirFFI::ArgHelper.cast_from_pointer(element_type, list[:data])
            list = self.class.wrap(element_type, list[:next])
          end
          rval
        end
      end

      module ListClassMethods
        def wrap elmttype, ptr
          super(ptr).tap do |it|
            break if it.nil?
            it.element_type = elmttype
          end
        end
      end

      module HashTableClassMethods
        def wrap keytype, valtype, ptr
          super(ptr).tap do |it|
            break if it.nil?
            it.key_type = keytype
            it.value_type = valtype
          end
        end
      end

      module HashTableInstanceMethods
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
            GirFFI::ArgHelper.utf8_to_inptr it
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
      end

      module ByteArrayInstanceMethods
        def to_string
          GirFFI::ArgHelper.ptr_to_utf8_length self[:data], self[:len]
        end
      end

      module ArrayInstanceMethods
        def to_a
          GirFFI::ArgHelper.ptr_to_typed_array(self.element_type,
                                               self[:data], self[:len])
        end
      end
    end
  end
end

