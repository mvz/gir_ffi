# frozen_string_literal: true

require "gir_ffi/user_defined_property_info"
require "gir_ffi/vfunc_implementation"

module GirFFI
  # Represents a user defined type, conforming, as needed, to the interface of
  # GObjectIntrospection::IObjectInfo.
  class UserDefinedObjectInfo
    attr_reader :properties, :vfunc_implementations

    def initialize(klass)
      @klass = klass
      @properties = []
      @vfunc_implementations = []

      # FIXME: Limit access to only install_property and install_vfunc_implementation.
      yield self if block_given?
    end

    def described_class
      @klass
    end

    def install_property(param_spec)
      @properties << param_spec
    end

    def install_vfunc_implementation(name, implementation = nil)
      @vfunc_implementations << VFuncImplementation.new(name, implementation)
    end

    def find_method(_method)
      nil
    end

    def find_instance_method(_method)
      nil
    end

    def find_property(_property)
      nil
    end

    def parent_gtype
      @parent_gtype ||= GType.new(@klass.superclass.gtype)
    end

    def parent
      @parent ||= gir.find_by_gtype(parent_gtype.to_i)
    end

    # TODO: Create custom class that includes the interfaces instead
    def class_struct
      nil
    end

    def interfaces
      (@klass.included_modules - @klass.superclass.included_modules).
        select { |m| m.respond_to?(:gir_info) }.map(&:gir_info)
    end

    def find_signal(_signal_name)
      nil
    end

    def abstract?
      false
    end

    attr_writer :g_name

    def g_name
      @g_name ||= @klass.name
    end

    private

    def gir
      @gir ||= GObjectIntrospection::IRepository.default
    end
  end
end
