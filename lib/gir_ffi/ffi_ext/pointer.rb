module GirFFI
  module FFIExt
    module Pointer
      def to_ptr
        self
      end

      def to_value
        self
      end
    end
  end
end

FFI::Pointer.send :include, GirFFI::FFIExt::Pointer
