# frozen_string_literal: true
require 'gir_ffi/class_base'

module GirFFI
  # Base class for generated classes representing boxed types.
  class BoxedBase < StructBase
    def initialize
      super
      gtype = self.class.gtype
      ObjectSpace.define_finalizer self, self.class.make_finalizer(@struct, gtype)
    end

    def self.make_finalizer(struct, gtype)
      proc do
        ptr = struct.to_ptr
        ptr.autorelease = false
        GObject.boxed_free gtype, struct.to_ptr
      end
    end
  end
end
