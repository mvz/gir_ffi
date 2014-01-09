require 'gir_ffi/type_base'

module GirFFI
  # Base module for modules representing GLib interfaces.
  module InterfaceBase
    include TypeBase

    def setup_instance_method name
      gir_ffi_builder.setup_instance_method name
    end

    def wrap ptr
      ptr.to_object
    end

    def to_ffitype
      :pointer
    end
  end
end
