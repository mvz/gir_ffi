require 'ffi'

module GirFFI
  module Library
    include FFI::Library

    def find_type type
      if type.is_a? Module
        if type.const_defined?(:Enum)
          return super type::Enum
        end
      end

      super
    end
  end
end
