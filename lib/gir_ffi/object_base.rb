# frozen_string_literal: true

require "gir_ffi/class_base"

module GirFFI
  # Base class for all generated classes of type :object.
  class ObjectBase < ClassBase
    extend FFI::DataConverter

    def class_struct
      self.class.class_struct
    end

    def self.native_type
      FFI::Type::POINTER
    end

    def self.to_ffi_type
      self
    end

    def self.to_native(obj, _context)
      obj.to_ptr
    end

    def self.get_value_from_pointer(pointer, offset = 0)
      pointer.get_pointer offset
    end

    def self.copy_value_to_pointer(value, pointer, offset = 0)
      pointer.put_pointer offset, value.to_ptr
    end

    # Wrap the passed pointer in an instance of its type's corresponding class,
    # generally assumed to be a descendant of the current type.
    def self.wrap(ptr)
      ptr.to_object
    end

    def self.copy_from(val)
      val&.ref
    end

    #
    # Find property info for the named property.
    #
    # @param name The property's name
    #
    # @return [GObjectIntrospection::IPropertyInfo] The property's info
    #
    def self.find_property(name)
      gir_ffi_builder.find_property name
    end

    #
    # Find signal info for the named signal.
    #
    # @param name The signal's name
    #
    # @return [GObjectIntrospection::ISignalInfo] The signal's info
    #
    def self.find_signal(name)
      gir_ffi_builder.find_signal name or
        raise GirFFI::SignalNotFoundError.new(name, self)
    end

    def self.class_struct
      @class_struct ||=
        begin
          ptr = GObject::Lib.g_type_class_ref(gtype)
          gir_ffi_builder.class_struct_class.wrap ptr
        end
    end

    def self.included_interfaces
      included_modules.select { _1.singleton_class.include? InterfaceBase }
    end

    def self.registered_ancestors
      ancestors.select do |klass|
        klass < GirFFI::ObjectBase || klass.singleton_class.include?(InterfaceBase)
      end
    end

    def self.prepare_user_defined_class
      return if const_defined? :GIR_INFO, false

      info = UserDefinedObjectInfo.new(self)
      const_set :GIR_INFO, info
    end

    def self.install_property(param_spec)
      if const_defined? :GIR_FFI_BUILDER, false
        raise "Installing a property in a class that is already set up is not supported"
      end

      prepare_user_defined_class

      gir_info.install_property(param_spec)
    end

    def self.install_vfunc_implementation(name, implementation = nil)
      if const_defined? :GIR_FFI_BUILDER, false
        raise "Installing a property in a class that is already set up is not supported"
      end

      prepare_user_defined_class

      gir_info.install_vfunc_implementation(name, implementation)
    end
  end
end
