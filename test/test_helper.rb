if RUBY_PLATFORM == 'java'
  require 'java'
  JRuby.objectspace = true
  require 'rubygems'
end

require 'minitest/spec'
require 'minitest/autorun'
require 'rr'
require 'ffi'

Thread.abort_on_exception = true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

class MiniTest::Unit::TestCase
  include RR::Adapters::TestUnit

  def get_introspection_data namespace, name
    gir = GObjectIntrospection::IRepository.default
    gir.require namespace, nil
    gir.find_by_name namespace, name
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
