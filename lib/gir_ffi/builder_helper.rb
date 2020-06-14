# frozen_string_literal: true

module GirFFI
  # Set of helper methods used in the builders.
  module BuilderHelper
    def optionally_define_constant(parent, name)
      if parent.const_defined? name, false
        parent.const_get name
      else
        parent.const_set name, yield
      end
    end

    def get_or_define_class(namespace, name, parent)
      klass = optionally_define_constant(namespace, name) { Class.new parent }
      unless klass.superclass == parent
        raise "Expected superclass #{parent}, found #{klass.superclass}"
      end

      klass
    end

    def get_or_define_module(parent, name)
      optionally_define_constant(parent, name) { Module.new }
    end
  end
end
