# frozen_string_literal: true

require 'base_test_helper'

require 'ffi-gobject_introspection'

GObjectIntrospection::IRepository.prepend_search_path File.join(File.dirname(__FILE__), 'lib')

module LocalSharedLibrary
  def shared_library(namespace)
    case namespace
    when 'Everything', 'GIMarshallingTests', 'Regress', 'Utility', 'WarnLib'
      File.join(File.dirname(__FILE__), 'lib', "lib#{namespace.downcase}.so")
    else
      super
    end
  end
end

GObjectIntrospection::IRepository.prepend LocalSharedLibrary

module IntrospectionTestExtensions
  class << self
    attr_accessor :version
  end

  def get_introspection_data(namespace, name)
    gir = GObjectIntrospection::IRepository.default
    gir.require namespace, nil
    gir.find_by_name namespace, name
  end

  def get_field_introspection_data(namespace, klass, name)
    get_introspection_data(namespace, klass).find_field name
  end

  def get_method_introspection_data(namespace, klass, name)
    get_introspection_data(namespace, klass).find_method name
  end

  def get_property_introspection_data(namespace, klass, name)
    get_introspection_data(namespace, klass).find_property name
  end

  def get_signal_introspection_data(namespace, klass, name)
    get_introspection_data(namespace, klass).find_signal name
  end

  def get_vfunc_introspection_data(namespace, klass, name)
    get_introspection_data(namespace, klass).find_vfunc name
  end

  def skip_below(introduction_version);
    unless LATEST_VERSION >= introduction_version
      raise "Version #{introduction_version} is too new and would always be skipped"
    end

    skip "Introduced in #{introduction_version}" if introduction_version > version
  end

  def version
    IntrospectionTestExtensions.version ||= calculate_version
  end

  VERSION_GUARDS = {
    '1.58.3'  => %w(Regress TestReferenceCounters),
    '1.57.2'  => %w(Regress TestInterface emit_signal),
    '1.55.2'  => %w(Regress FOO_FLAGS_SECOND_AND_THIRD),
    '1.53.4'  => %w(Regress TestObj name_conflict),
    '1.49.1'  => %w(Regress AnonymousUnionAndStruct),
    '1.47.92' => %w(Regress get_variant),
    '1.47.1'  => %w(Regress test_noptr_callback)
  }.freeze

  LATEST_VERSION = VERSION_GUARDS.keys.first

  def calculate_version
    VERSION_GUARDS.each do |version, (namespace, klass, methodname)|
      result = if methodname
                 get_method_introspection_data(namespace, klass, methodname)
               else
                 get_introspection_data(namespace, klass)
               end
      return version if result
    end

    '1.46.0' # Minimum supported version
  end
end

Minitest::Test.include IntrospectionTestExtensions
