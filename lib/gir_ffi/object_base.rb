require 'gir_ffi/class_base'

module GirFFI
  # Base class for all generated classes of type :object.
  class ObjectBase < ClassBase
    extend FFI::DataConverter

    def object_class
      self.class.object_class
    end

    def self.native_type
      FFI::Type::POINTER
    end

    def self.to_ffi_type
      self
    end

    def self.to_native(it, _)
      it.to_ptr
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

    #
    # Find property info for the named property.
    #
    # @param name The property's name
    #
    # @return [GObjectIntrospection::IPropertyInfo] The property's info
    #
    def self.find_property(name)
      gir_ffi_builder.find_property name or
        raise GirFFI::PropertyNotFoundError.new(name, self)
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

    def self.object_class
      @object_class ||=
        begin
          ptr = GObject.type_class_ref(gtype).to_ptr
          gir_ffi_builder.object_class_struct.wrap ptr
        end
    end
  end
end
