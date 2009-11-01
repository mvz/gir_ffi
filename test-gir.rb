require 'ffi'
module GObjectIntrospection
  extend FFI::Library

  ffi_lib "girepository-1.0"

  class Repository
    extend FFI::Library
    attach_function :g_irepository_get_default, [], :pointer

    def self.get_default
      @@singleton ||= Repository.new(g_irepository_get_default)
    end

    private

    def initialize(gobject)
      @gobj = gobject
    end
  end
end

gir = GObjectIntrospection::Repository.get_default
