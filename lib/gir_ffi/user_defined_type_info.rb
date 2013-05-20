require 'gir_ffi/user_defined_property_info'

module GirFFI
  class UserDefinedTypeInfo
    def initialize klass, &block
      @klass = klass
      @properties = []
      self.instance_eval(&block) if block
    end

    def described_class
      @klass
    end

    def install_property property
      @properties << UserDefinedPropertyInfo.new(property)
    end

    def properties
      @properties
    end
  end
end
