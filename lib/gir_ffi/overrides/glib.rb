module GirFFI
  module Overrides
    module GLib
      def self.included base
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
    end
  end
end

