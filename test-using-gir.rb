#
# Exploratory program to see what kind of method_missing we would need in a
# module. In the end, this code would have to be generated by the Builder,
# or be provided by a mixin.
#

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'girffi'

module GirFFI
  class ITypeInfo
    def to_ffi
      return :pointer if pointer?
      return GirFFI::IRepository.type_tag_to_string(tag).to_sym
    end
  end
end

module Gtk
  module Lib
    extend FFI::Library
    ffi_lib "gtk-x11-2.0"
  end

  @@gir = GirFFI::IRepository.default
  @@gir.require "Gtk", nil
  def self.method_missing method, *arguments
    go = @@gir.find_by_name "Gtk", method.to_s

    # TODO: Unwind stack of raised NoMethodError to get correct error
    # message.
    return super if go.nil?
    return super if go.type != :function

    sym = go.symbol
    argtypes = go.args.map {|a| a.type.to_ffi}
    argnames = go.args.map {|a| a.name}
    rt = go.return_type.to_ffi

    puts "attach_function :#{sym}, [#{argtypes.map {|a| ":#{a}"}.join ", "}], :#{rt}"
    Gtk.module_eval do
      Lib.module_eval do
	attach_function sym, argtypes, rt
      end
      eigenclass = class << self; self; end
      code = <<-CODE
	def #{method} #{argnames.join(', ')}
	  puts "Calling #{sym} #{argnames.map{|n| "\#{#{n}}"}.join(', ')}"
	  Lib.#{sym} #{argnames.join(', ')}
	end
      CODE
      puts code
      eigenclass.class_eval code
    end

    #puts Gtk.public_methods - Module.public_methods
    self.send method, *arguments
  end
end

Gtk.init 0, nil
Gtk.init 0, nil
Gtk.flub
