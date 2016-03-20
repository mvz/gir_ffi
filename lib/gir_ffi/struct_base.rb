# frozen_string_literal: true
require 'gir_ffi/struct_like_base'

module GirFFI
  # Base class for generated classes representing GLib structs.
  class StructBase < ClassBase
    extend FFI::DataConverter
    extend GirFFI::StructLikeBase

    def initialize
      @struct = self.class::Struct.new
    end

    # Wrap value and take ownership of it
    def self.wrap_own(val)
      wrap(val).tap { |it| it && it.to_ptr.autorelease = true }
    end

    # TODO: Wrap and own a copy of the passed-in value
    def self.wrap_copy(val)
      wrap(val)
    end
  end
end
