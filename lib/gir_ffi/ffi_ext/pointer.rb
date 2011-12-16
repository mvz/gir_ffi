module GirFFI
  module FFIExt
    module Pointer
      def to_ptr
        self
      end
    end
  end
end

FFI::Pointer.send :include, GirFFI::FFIExt::Pointer
