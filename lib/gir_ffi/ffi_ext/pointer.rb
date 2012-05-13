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
        # TODO: Move implementation here.
        ArgHelper.object_pointer_to_object self
      end
    end
  end
end

FFI::Pointer.send :include, GirFFI::FFIExt::Pointer
