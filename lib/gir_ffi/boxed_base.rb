# frozen_string_literal: true

require "gir_ffi/class_base"

module GirFFI
  # Base class for generated classes representing boxed types.
  class BoxedBase < StructLikeBase
    def self.make_finalizer(struct)
      proc { finalize(struct) }
    end

    def self.copy(val)
      return if val.to_ptr.null?

      ptr = GObject.boxed_copy(gtype, val)
      wrap(ptr)
    end

    class << self
      protected

      def finalize(struct)
        struct.owned? or return

        struct.owned = nil
        GObject.boxed_free gtype, struct.to_ptr
      end
    end

    private

    def store_pointer(*)
      super
      make_finalizer
    end

    def make_finalizer
      ObjectSpace.define_finalizer self, self.class.make_finalizer(struct)
    end
  end
end
