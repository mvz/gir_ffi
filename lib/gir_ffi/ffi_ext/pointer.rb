module GirFFI
  module FFIExt
    module Pointer
      def to_ptr
        self
      end

      def to_value
        self
      end

      def zero?
        null?
      end

      def to_object
        gtype = GObject.type_from_instance_pointer self
        wrap_by_gtype gtype
      end

      def wrap_by_gtype gtype
        return nil if self.null?
        klass = Builder.build_by_gtype gtype
        klass.direct_wrap self
      end

      def to_utf8
        null? ? nil : read_string.force_encoding("utf-8")
      end
    end
  end
end

# TODO: Move use to InPointer and InOutPointer?
FFI::Pointer.send :include, GirFFI::FFIExt::Pointer
