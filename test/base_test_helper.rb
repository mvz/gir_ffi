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
require 'minitest/rspec_mocks'

require 'gir_ffi-base'
require 'ffi-gobject_introspection'

GObjectIntrospection::IRepository.prepend_search_path File.join(File.dirname(__FILE__), 'lib')

module GObjectIntrospection
  class IRepository
    def shared_library_with_regress(namespace)
      case namespace
      when 'Everything', 'GIMarshallingTests', 'Regress', 'Utility', 'WarnLib'
        return File.join(File.dirname(__FILE__), 'lib', "lib#{namespace.downcase}.so")
      else
        return shared_library_without_regress namespace
      end
    end

    alias_method :shared_library_without_regress, :shared_library
    alias_method :shared_library, :shared_library_with_regress
  end
end

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
Minitest::Test.send :include, Minitest::RSpecMocks

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

# Override describe to automatically set cover information
def describe(desc, *additional_desc, &block)
  super.tap do |cls|
    unless cls.covering
      top_level = cls.describe_stack.first || cls
      cover_desc = top_level.covering || top_level.desc
      cls.cover cover_desc.to_s
    end
  end
end
