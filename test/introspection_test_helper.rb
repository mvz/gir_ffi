# frozen_string_literal: true
require 'base_test_helper'

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

    # TODO: Use prepend instead of alias method chaining
    alias_method :shared_library_without_regress, :shared_library
    alias_method :shared_library, :shared_library_with_regress
  end
end

module IntrospectionTestExtensions
  module_function

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
end

Minitest::Test.send :include, IntrospectionTestExtensions
