# frozen_string_literal: true

require 'rubygems' if RUBY_PLATFORM == 'java'

begin
  require 'simplecov'
  SimpleCov.start do
    track_files 'lib/**/*.rb'
    add_filter '/test/'
  end

  if ENV['CI']
    require 'coveralls'
    Coveralls.wear!
  end
rescue LoadError
end

require 'minitest/autorun'
require 'rspec/mocks/minitest_integration'

Thread.abort_on_exception = true

module BaseTestExtensions
  def assert_defines_singleton_method(klass, method, msg = nil)
    method = method.to_sym
    methods = klass.singleton_methods(false).map(&:to_sym)
    msg = message(msg) do
      "Expected #{mu_pp(klass)} to define singleton method #{mu_pp(method)}, " \
        "but only found #{mu_pp(methods)}"
    end
    assert_includes methods, method, msg
  end

  def refute_defines_singleton_method(klass, method, msg = nil)
    method = method.to_sym
    methods = klass.singleton_methods(false).map(&:to_sym)
    msg = message(msg) do
      "Expected #{mu_pp(klass)} not to define singleton method #{mu_pp(method)}"
    end
    refute_includes methods, method, msg
  end

  def assert_defines_instance_method(klass, method, msg = nil)
    method = method.to_sym
    methods = klass.instance_methods(false).map(&:to_sym)
    msg = message(msg) do
      "Expected #{mu_pp(klass)} to define instance method #{mu_pp(method)}, " \
        "but only found #{mu_pp(methods)}"
    end
    assert_includes methods, method, msg
  end

  def refute_defines_instance_method(klass, method, msg = nil)
    method = method.to_sym
    methods = klass.instance_methods(false).map(&:to_sym)
    msg = message(msg) do
      "Expected #{mu_pp(klass)} not to define instance method #{mu_pp(method)}"
    end
    refute_includes methods, method, msg
  end
end

Minitest::Test.send :include, BaseTestExtensions
