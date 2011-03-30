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
      end
    end
  end
end

