# frozen_string_literal: true
module GirFFI
  # Exception class to be raised when a property is not found.
  class PropertyNotFoundError < RuntimeError
    attr_reader :property_name

    def initialize(property_name, klass)
      @property_name = property_name
      @klass = klass
      super "Property '#{property_name}' not found in #{klass}"
    end
  end
end
