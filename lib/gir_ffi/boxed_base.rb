# frozen_string_literal: true
require 'gir_ffi/class_base'

module GirFFI
  # Base class for generated classes representing boxed types.
  class BoxedBase < StructBase
    def initialize
      store_pointer(nil)
    end

    def self.make_finalizer(struct, gtype)
      proc do
        if struct.owned?
          struct.owned = false
          GObject.boxed_free gtype, struct.to_ptr
        end
      end
    end

    def self.copy(val)
      return unless val
      ptr = GObject.boxed_copy(gtype, val)
      wrap(ptr)
    end

    private

    def store_pointer(ptr)
      super
      make_finalizer
    end

    def make_finalizer
      gtype = self.class.gtype
      ObjectSpace.define_finalizer self, self.class.make_finalizer(@struct, gtype)
    end
  end
end
