# frozen_string_literal: true

module GirFFI
  # Methods for setting up class methods
  module MethodSetup
    def setup_method(name)
      gir_ffi_builder.setup_method name
    end

    def setup_method!(name)
      setup_method name or raise "Unknown method #{name}"
    end
  end
end
