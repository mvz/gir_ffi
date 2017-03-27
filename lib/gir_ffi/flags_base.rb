# frozen_string_literal: true

require 'gir_ffi/enum_like_base'

module GirFFI
  # Base module for flags.
  module FlagsBase
    include EnumLikeBase

    def native_type
      self::BitMask.native_type
    end

    def to_native(value, context)
      case value
      when Symbol
        value = { value => true }
      end
      self::BitMask.to_native(value, context)
    end

    def from_native(*args)
      self::BitMask.from_native(*args).select { |_k, v| v }
    end

    def [](arg)
      self::BitMask[arg]
    end
  end
end
