require 'contest'
require 'rr'
require 'ffi'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

if RUBY_PLATFORM == 'java'
  require 'java'
  JRuby.objectspace = true
end

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
  include RR::Adapters::TestUnit
  def cws code
    code.gsub(/(^\s*|\s*$)/, "")
  end

  def get_function_introspection_data namespace, function
    gir = GirFFI::IRepository.default
    gir.require namespace, nil
    gir.find_by_name namespace, function
  end

  def get_method_introspection_data namespace, klass, function
    gir = GirFFI::IRepository.default
    gir.require namespace, nil
    gir.find_by_name(namespace, klass).find_method function
  end

  def cleanup_module name
    if Object.const_defined? name
      Object.send(:remove_const, name)
    end
  end
end
