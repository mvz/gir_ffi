# frozen_string_literal: true

require "base_test_helper"

require "ffi-gobject_introspection"

module IntrospectionTestExtensions
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
    if introduction_version > LATEST_VERSION
      raise "Version #{introduction_version} is too new causing test to always be skipped"
    end

    skip "Introduced in #{introduction_version}" if version < introduction_version
  end

  def skip_above(last_available_version, message = nil)
    if last_available_version < EARLIEST_VERSION
      raise "Version #{last_available_version} is too old causing test to always be skipped"
    end

    if version > last_available_version
      skip message || "Removed after #{last_available_version}"
    end
  end

  def version
    IntrospectionTestExtensions.version ||= calculate_version
  end

  VERSION_GUARDS = {
    "1.83.2" => %w[Regress foo_init_argv],
    "1.81.2" => %w[GIMarshallingTests dev_t_in],
    "1.80.1" => %w[Everything const_return_off_t],
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
  EARLIEST_VERSION = "1.56.0"

  def calculate_version
    VERSION_GUARDS.each do |version, (namespace, class_or_function, method_name)|
      result = if method_name
                 get_method_introspection_data(namespace, class_or_function, method_name)
               else
                 get_introspection_data(namespace, class_or_function)
               end
      return version if result
    end

    EARLIEST_VERSION # Minimum supported version
  end
end

GObjectIntrospection::IRepository
  .prepend_search_path File.join(File.dirname(__FILE__), "lib")
GObjectIntrospection::IRepository.prepend IntrospectionTestExtensions::LocalSharedLibrary
Minitest::Test.include IntrospectionTestExtensions
