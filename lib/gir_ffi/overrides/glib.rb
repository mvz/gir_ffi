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
          include ListInstanceMethods
          include Enumerable
        }
        base::List.class_eval {
          include ListInstanceMethods
          include Enumerable
        }
        base::HashTable.class_eval {
          include HashTableInstanceMethods
          include Enumerable
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
      end

      module ClassMethods
        # FIXME: Should not be so visible for end users.
        def slist_prepend slist, data
          ::GLib::SList.wrap(::GLib::Lib.g_slist_prepend slist, data)
        end

        # FIXME: Should not be so visible for end users.
        def list_append list, data
          ::GLib::List.wrap(::GLib::Lib.g_list_append list, data)
        end

        # FIXME: Turn into real constructor
        def hash_table_new
          ::GLib::HashTable.wrap(::GLib::Lib.g_hash_table_new nil, nil)
        end
      end

      module ListInstanceMethods
        def each
          list = self
          rval = nil
          until list.nil?
            rval = yield GirFFI::ArgHelper.ptr_to_utf8(list[:data])
            list = self.class.wrap(list[:next])
          end
          rval
        end
      end

      module HashTableInstanceMethods
        def each
          prc = Proc.new {|keyptr, valptr, userdata|
            key = GirFFI::ArgHelper.ptr_to_utf8 keyptr
            val = GirFFI::ArgHelper.ptr_to_utf8 valptr
            yield key, val
          }
          ::GLib::Lib.g_hash_table_foreach self.to_ptr, prc, nil
        end

        def to_hash
          Hash[self.to_a]
        end

        def insert key, value
          keyptr = GirFFI::ArgHelper.utf8_to_inptr key
          valptr = GirFFI::ArgHelper.utf8_to_inptr value
          ::GLib::Lib.g_hash_table_insert self.to_ptr, keyptr, valptr
        end
      end

    end
  end
end

