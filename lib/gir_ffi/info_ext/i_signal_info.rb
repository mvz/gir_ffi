module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::ISignalInfo needed by GirFFI
    module ISignalInfo
      # Create a signal hander callback. Wraps the given block in such a way that
      # arguments and return value are cast correctly to the ruby world and back.
      #
      # @param  block   The body of the signal handler
      #
      # @return [FFI::Function] The signal handler, ready to be passed as a
      #   callback to C.
      def create_callback &block
        raise ArgumentError, "Block needed" unless block

        # TODO: Find the signal module directly, then retrieve the info
        # from that, instead of vice versa.
        bldr = Builders::SignalBuilder.new(self)
        wrapped = bldr.build_class.from(block)
        # FIXME: Logically, this should use CallbackBase#to_native
        FFI::Function.new return_ffi_type, ffi_callback_argument_types, &wrapped
      end

      # TODO: Use argument info to convert out arguments and array lengths.
      def arguments_to_gvalue_array_pointer object, args
        arr = arguments_to_gvalues object, args
        GirFFI::InPointer.from_array GObject::Value, arr
      end

      def arguments_to_gvalues instance, arguments
        arg_values = self.args.zip(arguments).map do |info, arg|
          info.argument_type.make_g_value.set_value(arg)
        end

        arg_values.unshift GObject::Value.wrap_instance(instance)
      end

      def gvalue_for_return_value
        return_type.make_g_value
      end

      # TODO: Rename and clarify relation to argument_ffi_types:
      # The types returned by ffi_callback_argument_types are more basic than
      # those returned by argument_ffi_types. Is there a way to make these
      # methods more related? Perhaps argument_ffi_types can return more basic
      # types as well?
      def ffi_callback_argument_types
        types = args.map do |arg|
          arg.to_callback_ffitype
        end
        types.unshift(:pointer).push(:pointer)
      end

      def return_ffi_type
        result = return_type.to_ffitype
        if result == GLib::Boolean
          :bool
        else
          result
        end
      end
    end
  end
end

GObjectIntrospection::ISignalInfo.send :include, GirFFI::InfoExt::ISignalInfo
