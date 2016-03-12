# frozen_string_literal: true
require 'gir_ffi/class_base'

module GirFFI
  # Base class for generated classes representing boxed types.
  class BoxedBase < StructBase
    def initialize
      store_pointer(self.class::Struct.new.to_ptr)
    end

    def self.make_finalizer(ptr, gtype)
      proc do
        if ptr.autorelease?
          ptr.autorelease = false
          GObject.boxed_free gtype, ptr
        end
      end
    end

    private

    def store_pointer(ptr)
      super
      make_finalizer
    end

    def make_finalizer
      gtype = self.class.gtype
      ObjectSpace.define_finalizer self, self.class.make_finalizer(to_ptr, gtype)
    end
  end
end
