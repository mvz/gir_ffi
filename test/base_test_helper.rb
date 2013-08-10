if RUBY_PLATFORM == 'java'
  require 'rubygems'
end

if RUBY_VERSION >= "1.9"
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
  end
end

require 'minitest/autorun'
require 'rr'

require 'gir_ffi-base'
require 'ffi-gobject_introspection'

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

Thread.abort_on_exception = true

class Minitest::Test
  include RR::Adapters::TestUnit

  def assert_defines_singleton_method klass, method, msg = nil
    method = method.to_sym
    methods = klass.singleton_methods(false).map { |name| name.to_sym }
    msg = message(msg) {
      "Expected #{mu_pp(klass)} to define singleton method #{mu_pp(method)}, " +
        "but only found #{mu_pp(methods)}"
    }
    assert_includes methods, method, msg
  end

  def refute_defines_singleton_method klass, method, msg = nil
    method = method.to_sym
    methods = klass.singleton_methods(false).map { |name| name.to_sym }
    msg = message(msg) {
      "Expected #{mu_pp(klass)} not to define singleton method #{mu_pp(method)}"
    }
    refute_includes methods, method, msg
  end

  def assert_defines_instance_method klass, method, msg = nil
    method = method.to_sym
    methods = klass.instance_methods(false).map { |name| name.to_sym }
    msg = message(msg) {
      "Expected #{mu_pp(klass)} to define instance method #{mu_pp(method)}, " +
        "but only found #{mu_pp(methods)}"
    }
    assert_includes methods, method, msg
  end

  def refute_defines_instance_method klass, method, msg = nil
    method = method.to_sym
    methods = klass.instance_methods(false).map { |name| name.to_sym }
    msg = message(msg) {
      "Expected #{mu_pp(klass)} not to define instance method #{mu_pp(method)}"
    }
    refute_includes methods, method, msg
  end
end

class Minitest::Spec
  class << self
    alias :setup :before
    alias :should :it
  end
end
