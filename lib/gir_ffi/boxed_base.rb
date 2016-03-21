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

    # Create an unowned copy of the struct represented by val
    def self.copy_from(val)
      copy from(val)
    end

    # Wrap an owned copy of the struct represented by val
    def self.wrap_copy(val)
      copy(wrap(val)).tap { |it| it && it.to_ptr.autorelease = true }
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
      ObjectSpace.define_finalizer self, self.class.make_finalizer(to_ptr, gtype)
    end
  end
end
