# frozen_string_literal: true
require 'gir_ffi/enum_like_base'

module GirFFI
  # Base module for enums.
  module EnumBase
    include EnumLikeBase

    def native_type
      self::Enum.native_type
    end

    def to_native(*args)
      self::Enum.to_native(*args)
    end

    def from_native(*args)
      self::Enum.from_native(*args)
    end

    def [](arg)
      self::Enum[arg]
    end
  end
end
