require 'shoulda'
require 'ffi'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

# Since the tests will call Gtk+ functions, Gtk+ must be initialized.
module DummyGtk
  module Lib
    extend FFI::Library

    ffi_lib "gtk-x11-2.0"
    attach_function :gtk_init, [:pointer, :pointer], :void
  end

  def self.init
    Lib.gtk_init nil, nil
  end
end

DummyGtk.init

# Need a dummy module for some tests.
module Lib
end

class Test::Unit::TestCase
  def cws code
    code.gsub(/(^\s*|\s*$)/, "")
  end
end
