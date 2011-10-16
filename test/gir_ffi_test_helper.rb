require File.expand_path('test_helper.rb', File.dirname(__FILE__))

require 'gir_ffi'

GObjectIntrospection::IRepository.prepend_search_path File.join(File.dirname(__FILE__), 'lib')
module GObjectIntrospection
  class IRepository
    def shared_library_with_regress namespace
      case namespace
      when "Regress"
	return File.join(File.dirname(__FILE__), 'lib', 'libregress.so')
      when "GIMarshallingTests"
	return File.join(File.dirname(__FILE__), 'lib', 'libgimarshallingtests.so')
      else
	return shared_library_without_regress namespace
      end
    end

    alias shared_library_without_regress shared_library
    alias shared_library shared_library_with_regress
  end
end

# Preload data for Gtk+ version 2.0.
gir = GObjectIntrospection::IRepository.default
gir.require "Gtk", "2.0"

# Need a dummy module for some tests.
module Lib
end

class MiniTest::Unit::TestCase
  def cws code
    code.gsub(/(^\s*|\s*$)/, "")
  end

  def get_method_introspection_data namespace, klass, name
    get_introspection_data(namespace, klass).find_method name
  end

  SAVED_MODULES = {}

  def save_module name
    if Object.const_defined? name
      puts "Saving #{name} over existing" if SAVED_MODULES.has_key? name
      SAVED_MODULES[name] = Object.const_get name
      Object.send(:remove_const, name)
    end
  end

  def restore_module name
    if SAVED_MODULES.has_key? name
      if Object.const_defined? name
        Object.send(:remove_const, name)
      end
      Object.const_set name, SAVED_MODULES[name]
      SAVED_MODULES.delete name
    end
  end

  def ref_count object
    GObject::Object::Struct.new(object.to_ptr)[:ref_count]
  end

  def is_floating? object
    (GObject::Object::Struct.new(object.to_ptr)[:qdata].address & 2) == 2
  end

  def max_for_unsigned_type type
    ( 1 << (FFI.type_size(type) * 8) ) - 1
  end

  def max_for_type type
    ( 1 << (FFI.type_size(type) * 8 - 1) ) - 1
  end

  def min_for_type type
    ~max_for_type(type)
  end

  def max_long
    max_for_type :long
  end

  def min_long
    min_for_type :long
  end

  def max_size_t
    max_for_unsigned_type :size_t
  end

  def max_ssize_t
    # FFI has no :ssize_t, but it's the same number of bits as :size_t
    max_for_type :size_t
  end

  def min_ssize_t
    min_for_type :size_t
  end

  def max_ushort
    max_for_unsigned_type :ushort
  end

  def max_uint
    max_for_unsigned_type :uint
  end

  def max_ulong
    max_for_unsigned_type :ulong
  end
end

