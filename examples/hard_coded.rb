# Hard-code FFI-based Gtk+ test program. Nothing is generated here.
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

  def self.signal_connect_data gobject, signal, prc, data, destroy_data, connect_flags
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
    attach_function :gtk_widget_destroy, [:pointer], :void
    attach_function :gtk_container_add, [:pointer, :pointer], :void

    enum :GtkWindowType, [:GTK_WINDOW_TOPLEVEL, :GTK_WINDOW_POPUP]
    attach_function :gtk_window_new, [:GtkWindowType], :pointer
    attach_function :gtk_button_new, [], :pointer
    attach_function :gtk_button_new_with_label, [:string], :pointer
    attach_function :gtk_label_new, [:string], :pointer
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

  # Note: This implementation would dump core if the garbage collector runs
  # before the contents of the pointers is used.
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
    def destroy
      Lib.gtk_widget_destroy(@gobj)
    end
    def to_ptr
      @gobj
    end
  end

  class Container < Widget
    def add widget
      Lib.gtk_container_add self.to_ptr, widget.to_ptr
    end
  end

  class Window < Container
    def initialize type
      @gobj = Lib.gtk_window_new(type)
    end
  end

  class Button < Container
    def initialize ptr
      @gobj = ptr
    end
    class << self
      alias :real_new :new
    end
    def self.new
      self.real_new Lib.gtk_button_new()
    end
    def self.new_with_label text
      self.real_new Lib.gtk_button_new_with_label(text)
    end
  end
end

(my_len, my_args) = Gtk.init ARGV.length + 1, [$0, *ARGV]
p my_len, my_args
win = Gtk::Window.new(:GTK_WINDOW_TOPLEVEL)
btn = Gtk::Button.new_with_label('Hello World')
win.add btn

quit_prc = Proc.new { Gtk.main_quit }

# We can create callbacks with a different signature by using FFI::Function
# directly.
del_prc = FFI::Function.new(:bool, [:pointer, :pointer]) {|a, b|
  puts "delete event occured"
  true
}
GObject.signal_connect_data(win, "destroy", quit_prc, nil, nil, 0)
GObject.signal_connect_data(win, "delete-event", del_prc, nil, nil, 0)
GObject.signal_connect_data(btn, "clicked", Proc.new { win.destroy }, nil, nil, :SWAPPED)

btn.show
win.show
Gtk.main
