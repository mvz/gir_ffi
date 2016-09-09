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

# Provide methods needed for integration with mutant
module ForMutant
  # Mark the current test class as covering the given expression.
  def cover(expression)
    @expression = expression
  end

  # Return the currently set covering expression.
  def covering
    defined?(@expression) && @expression
  end

  # Return the cover expression, but raise an exception if it is not defined.
  # This is the method used by mutant to fetch the coverage information.
  def cover_expression
    raise "Cover expression for #{self} is not specified" unless @expression
    @expression
  end
end

Minitest::Test.send :extend, ForMutant

def cover_expression_for(cls)
  full_stack = cls.describe_stack.dup << cls
  full_stack.reverse_each do |level|
    return level.covering if level.covering
    return level.desc.to_s if level.desc.is_a? Module
  end
  full_stack.first.desc.to_s
end

# Override describe to automatically set cover information
def describe(desc, *additional_desc, &block)
  super.tap do |cls|
    cls.cover cover_expression_for(cls) unless cls.covering
  end
end
