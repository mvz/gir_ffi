# frozen_string_literal: true

require "base_test_helper"

require "ffi-gobject_introspection"

GObjectIntrospection::IRepository
  .prepend_search_path File.join(File.dirname(__FILE__), "lib")

module LocalSharedLibrary
  def shared_library(namespace)
    case namespace
    when "Everything", "GIMarshallingTests", "Regress", "Utility", "WarnLib"
      File.join(File.dirname(__FILE__), "lib", "lib#{namespace.downcase}.so")
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

  def skip_below(introduction_version)
    unless LATEST_VERSION >= introduction_version
      raise "Version #{introduction_version} is too new and would always be skipped"
    end

    skip "Introduced in #{introduction_version}" if introduction_version > version
  end

  def version
    IntrospectionTestExtensions.version ||= calculate_version
  end

  VERSION_GUARDS = {
    "1.71.0" => %w[Regress TestFundamentalObjectNoGetSetFunc],
    "1.69.0" => %w[Regress TestObj get_string],
    "1.67.1" => %w[GIMarshallingTests SignalsObject],
    "1.66.1" => %w[GIMarshallingTests Object vfunc_return_flags],
    "1.66.0" => %w[GIMarshallingTests Object vfunc_multiple_inout_parameters],
    "1.61.3" => %w[Regress test_array_static_in_int],
    "1.61.1" => %w[Regress TestObj emit_sig_with_error],
    "1.59.4" => %w[Regress test_array_struct_in_none],
    "1.58.3" => %w[Regress TestReferenceCounters],
    "1.57.2" => %w[Regress TestInterface emit_signal]
  }.freeze

  LATEST_VERSION = VERSION_GUARDS.keys.first

  def calculate_version
    VERSION_GUARDS.each do |version, (namespace, class_or_function, method_name)|
      result = if method_name
                 get_method_introspection_data(namespace, class_or_function, method_name)
               else
                 get_introspection_data(namespace, class_or_function)
               end
      return version if result
    end

    "1.56.0" # Minimum supported version
  end
end

Minitest::Test.include IntrospectionTestExtensions
