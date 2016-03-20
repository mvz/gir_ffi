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

    # Wrap an owned copy of the struct represented by val
    def self.wrap_copy(val)
      copy wrap(val)
    end

    def self.copy(val)
      return unless val
      new.tap { |copy| copy_value_to_pointer(val, copy.to_ptr) }
    end
  end
end
