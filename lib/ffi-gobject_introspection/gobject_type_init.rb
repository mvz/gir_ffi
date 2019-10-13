# frozen_string_literal: true

require "ffi"

module GObjectIntrospection
  # Provides access to the g_type_init function.
  module GObjectTypeInit
    def self.type_init
      Lib.g_type_init
    end

    # Module for attaching g_type_init from the gobject library.
    module Lib
      extend FFI::Library
      ffi_lib "gobject-2.0"
      attach_function :g_type_init, [], :void
    end
  end
end
