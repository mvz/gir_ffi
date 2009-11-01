require 'ffi'

module GLib
  private
  module Lib
    extend FFI::Library
    ffi_lib "gobject-2.0"
    attach_function :g_type_init, [], :void
  end

  public
  class GType
    def self.init; Lib::g_type_init; end
  end
end
module GI
  private

  module Lib
    extend FFI::Library
    ffi_lib "girepository-1.0"
    attach_function :g_irepository_get_default, [], :pointer
  end

  public

  class Repository

    def self.get_default
      @@singleton ||= Repository.new(Lib::g_irepository_get_default)
    end

    private

    def initialize(gobject)
      @gobj = gobject
    end
  end
end

GLib::GType.init

gir = GI::Repository.get_default
p gir
