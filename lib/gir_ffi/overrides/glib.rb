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
    end
  end
end

