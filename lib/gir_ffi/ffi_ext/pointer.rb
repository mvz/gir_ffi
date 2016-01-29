module GirFFI
  module FFIExt
    # Extensions to FFI::Pointer
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

      # FIXME: Should probably not be here.
      def to_object
        return nil if null?
        gtype = GObject.type_from_instance_pointer self
        Builder.build_by_gtype(gtype).direct_wrap self
      end

      def to_utf8
        null? ? nil : read_string.force_encoding('utf-8')
      end
    end
  end
end

# TODO: Move use to InPointer and InOutPointer?
FFI::Pointer.send :include, GirFFI::FFIExt::Pointer
