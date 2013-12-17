require 'gir_ffi/user_defined_property_info'
require 'gir_ffi/vfunc_implementation'

module GirFFI
  # Represents a user defined type, conforming, as needed, to the interface of
  # GObjectIntrospection::IObjectInfo.
  class UserDefinedTypeInfo
    attr_reader :properties, :vfunc_implementations

    def initialize klass
      @klass = klass
      @properties = []
      @vfunc_implementations = []
      yield self if block_given?
    end

    def described_class
      @klass
    end

    def install_property property
      @properties << UserDefinedPropertyInfo.new(property)
    end

    def install_vfunc_implementation name, implementation
      @vfunc_implementations << VFuncImplementation.new(name, implementation)
    end

    def find_instance_method _method
      nil
    end

    attr_writer :g_name

    def g_name
      @g_name ||= @klass.name
    end
  end
end
