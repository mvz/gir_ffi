# frozen_string_literal: true

require 'gir_ffi/struct_like_base'

module GirFFI
  # Base class for generated classes representing GLib structs.
  class StructBase < ClassBase
    extend FFI::DataConverter
    include GirFFI::StructLikeBase

    def initialize
      @struct = self.class::Struct.new
      @struct.owned = true
      @struct.to_ptr.autorelease = false
    end
  end
end
