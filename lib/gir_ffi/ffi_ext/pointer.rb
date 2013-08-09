module GirFFI
  module FFIExt
    module Pointer
      def to_ptr
        self
      end

      def to_value
        self
      end

      def to_object
        gtype = GObject.type_from_instance_pointer self
        ArgHelper.wrap_object_pointer_by_gtype self, gtype
      end
    end
  end
end

# TODO: Move use to InPointer and InOutPointer?
FFI::Pointer.send :include, GirFFI::FFIExt::Pointer
