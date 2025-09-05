# frozen_string_literal: true

require "gir_ffi/enum_like_base"

module GirFFI
  # Base module for enums.
  module EnumBase
    include EnumLikeBase

    def native_type
      self::Enum.native_type
    end

    def to_native(*)
      self::Enum.to_native(*)
    end

    def from_native(*)
      self::Enum.from_native(*)
    end

    def [](arg)
      self::Enum[arg]
    end
  end
end
