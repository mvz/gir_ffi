if RUBY_PLATFORM == 'java'
  require 'rubygems'
end

if RUBY_VERSION >= "1.9"
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/spec'
require 'minitest/autorun'
require 'rr'

Thread.abort_on_exception = true

class MiniTest::Unit::TestCase
  include RR::Adapters::TestUnit

  def assert_nothing_raised
    yield
    assert true
  end

  def assert_not_nil it
    refute_nil it
  end

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

class MiniTest::Spec
  class << self
    alias :setup :before
    alias :teardown :after
    alias :should :it
    alias :context :describe
  end
end

require 'gir_ffi-base'
