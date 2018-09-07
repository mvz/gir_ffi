# frozen_string_literal: true

module GirFFI
  # Methods for setting up instance methods
  module InstanceMethodSetup
    def setup_instance_method(name)
      gir_ffi_builder.setup_instance_method name
    end

    def setup_instance_method!(name)
      setup_instance_method name or raise "Unknown method #{name}"
    end
  end
end
