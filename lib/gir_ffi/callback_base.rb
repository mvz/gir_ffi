# frozen_string_literal: true
require 'gir_ffi/type_base'

module GirFFI
  # Base module for callbacks and vfuncs.
  # NOTE: Another option would be to derive this class from FFI::Function,
  # allowing a more natural implementation of from_native, to_native and wrap.
  class CallbackBase < Proc
    extend TypeBase
    extend FFI::DataConverter

    def self.native_type
      FFI::Type::POINTER
    end

    def self.from_native(value, _context)
      return nil if !value || value.null?
      FFI::Function.new(gir_ffi_builder.return_ffi_type,
                        gir_ffi_builder.argument_ffi_types, value)
    end

    def self.to_native(value, _context)
      case value
      when CallbackBase
        value.to_native
      when FFI::Function
        value
      end
    end

    def self.wrap(ptr)
      from_native ptr, nil
    end

    CALLBACKS = {}

    def self.store_callback(prc)
      CALLBACKS[prc.object_id] = prc
    end

    def self.drop_callback(prc)
      CALLBACKS.delete prc.object_id
    end

    # Create Callback from a Proc. Makes sure arguments are properly wrapped,
    # and the callback is stored to prevent garbage collection.
    def self.from(prc)
      wrap_proc(prc).tap do |cb|
        store_callback cb
      end
    end

    def self.wrap_proc(prc)
      return unless prc

      new do |*args|
        begin
          call_with_argument_mapping(prc, *args)
        rescue => e
          GLib::MainLoop.handle_exception e
        end
      end
    end

    def self.to_ffi_type
      self
    end

    def to_native
      @to_native ||= begin
                       builder = self.class.gir_ffi_builder
                       FFI::Function.new(builder.return_ffi_type,
                                         builder.argument_ffi_types, self)
                     end
    end

    def self.copy_value_to_pointer(value, pointer)
      pointer.put_pointer 0, to_native(value, nil)
    end

    def self.get_value_from_pointer(pointer, offset)
      from_native pointer.get_pointer(offset), nil
    end
  end
end
