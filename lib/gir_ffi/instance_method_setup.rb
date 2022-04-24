# frozen_string_literal: true

module GirFFI
  # Methods for setting up instance methods.
  #
  # Depends on .gir_ffi_builder being defined in the extending class.
  module InstanceMethodSetup
    def setup_instance_method(name)
      gir_ffi_builder.setup_instance_method name
    end

    def setup_instance_method!(name)
      setup_instance_method name or raise "Unknown method #{name}"
    end
  end
end
