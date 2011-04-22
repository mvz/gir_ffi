require 'minitest/spec'
require 'minitest/autorun'
require 'rr'
require 'ffi'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'gir_ffi'

if RUBY_PLATFORM == 'java'
  require 'java'
  JRuby.objectspace = true
end

# Since the tests will call Gtk+ functions, Gtk+ must be initialized.
GirFFI.setup :Gtk, '2.0'
Gtk.init

GirFFI::IRepository.prepend_search_path File.join(File.dirname(__FILE__), 'lib')
module GirFFI
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

# Need a dummy module for some tests.
module Lib
end

class MiniTest::Unit::TestCase
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

  def ref_count object
    GObject::Object::Struct.new(object.to_ptr)[:ref_count]
  end

  def is_floating? object
    (GObject::Object::Struct.new(object.to_ptr)[:qdata].address & 2) == 2
  end

  def assert_nothing_raised
    yield
    assert true
  end

  def assert_not_nil it
    refute_nil it
  end
end

class MiniTest::Spec
  class << self
    alias :setup :before
    alias :teardown :after
    alias :should :it
    alias :context :describe
  end
end
