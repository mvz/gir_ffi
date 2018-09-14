# frozen_string_literal: true

require 'gir_ffi/error_type_info'

module GirFFI
  # Represents an error argument with the same interface as IArgInfo
  class ErrorArgumentInfo
    def direction
      :error
    end

    def argument_type
      @argument_type ||= ErrorTypeInfo.new
    end

    def name
      '_error'
    end
  end
end
