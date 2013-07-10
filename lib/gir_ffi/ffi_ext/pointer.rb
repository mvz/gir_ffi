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

      # XXX: int32 is size 4, bool is size 1. Why u no crash?
      def put_bool offset, value
        int = value ? 1 : 0
        put_int32 offset, int
      end

      # XXX: int32 is size 4, bool is size 1. Why u no crash?
      def get_bool offset
        int = get_int32 offset
        return (int != 0)
      end
    end
  end
end

FFI::Pointer.send :include, GirFFI::FFIExt::Pointer
