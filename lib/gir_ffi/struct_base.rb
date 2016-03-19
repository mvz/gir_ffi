# frozen_string_literal: true
require 'gir_ffi/struct_like_base'

module GirFFI
  # Base class for generated classes representing GLib structs.
  class StructBase < ClassBase
    extend FFI::DataConverter
    extend GirFFI::StructLikeBase

    def initialize
      @struct = self.class::Struct.new
      gtype = self.class.gtype
      if GObject.type_fundamental(gtype) == GObject::TYPE_BOXED
        ObjectSpace.define_finalizer self, self.class.make_finalizer(@struct, gtype)
      end
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
