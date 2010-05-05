require 'ffi'
module GObject

  module Lib
    extend FFI::Library
    CALLBACKS = []
    ffi_lib "gobject-2.0"
    callback :GCallback, [], :void
    enum :GConnectFlags, [:AFTER, (1<<0), :SWAPPED, (1<<1)]

    attach_function :g_signal_connect_data, [:pointer, :string, :GCallback,
      :pointer, :pointer, :GConnectFlags], :ulong
  end

  def self.signal_connect_data gobject, signal, data, destroy_data, connect_flags, &block
    prc = block.to_proc
    Lib::CALLBACKS << prc
    Lib.g_signal_connect_data gobject.to_ptr, signal, prc, data, destroy_data, connect_flags
  end
end

module Gtk
  module Lib
    extend FFI::Library

    ffi_lib "gtk-x11-2.0"
    attach_function :gtk_init, [:pointer, :pointer], :void
    attach_function :gtk_main, [], :void
    attach_function :gtk_main_quit, [], :void

    attach_function :gtk_widget_show, [:pointer], :pointer

    enum :GtkWindowType, [:GTK_WINDOW_TOPLEVEL, :GTK_WINDOW_POPUP]
    attach_function :gtk_window_new, [:GtkWindowType], :pointer
  end

  def self.init size, ary
    argv = self.string_array_to_inoutptr ary
    argc = self.int_to_inoutptr(size)

    Lib.gtk_init argc, argv

    outsize = self.outptr_to_int argc
    outary = self.outptr_to_string_array argv, ary.nil? ? 0 : ary.size

    return outsize, outary
  end

  def self.int_to_inoutptr val
    ptr = FFI::MemoryPointer.new(:int)
    ptr.write_int val
    return ptr
  end

  def self.string_array_to_inoutptr ary
    ptrs = ary.map {|a| FFI::MemoryPointer.from_string(a)}
    block = FFI::MemoryPointer.new(:pointer, ptrs.length)
    block.write_array_of_pointer ptrs
    argv = FFI::MemoryPointer.new(:pointer)
    argv.write_pointer block
    argv
  end

  def self.outptr_to_int ptr
    return ptr.read_int
  end

  def self.outptr_to_string_array ptr, size
    block = ptr.read_pointer
    ptrs = block.read_array_of_pointer(size)
    return ptrs.map {|p| p.null? ? nil : p.read_string}
  end

  def self.main; Lib.gtk_main; end
  def self.main_quit; Lib.gtk_main_quit; end

  class Widget
    def show
      Lib.gtk_widget_show(@gobj)
    end
    def to_ptr
      @gobj
    end
  end

  class Window < Widget
    def initialize type
      @gobj = Lib.gtk_window_new(type)
    end
  end
end

(my_len, my_args) = Gtk.init ARGV.length, ARGV
p my_len, my_args
win = Gtk::Window.new(:GTK_WINDOW_TOPLEVEL)
win.show
GObject.signal_connect_data(win, "destroy", nil, nil, 0) { Gtk.main_quit }
Gtk.main
