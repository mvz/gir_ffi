# frozen_string_literal: true
require 'base_test_helper'

require 'ffi-gobject_introspection'

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
