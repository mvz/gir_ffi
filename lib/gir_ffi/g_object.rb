require 'ffi'

module GirFFI
  module GObject
    def self.type_init
      Lib::g_type_init
    end

    module Lib
      extend FFI::Library
      ffi_lib "gobject-2.0"
      attach_function :g_type_init, [], :void
    end
  end
end


