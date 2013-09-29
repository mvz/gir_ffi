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
        rettype = self.return_ffi_type
        argtypes = self.ffi_callback_argument_types

        raise ArgumentError, "Block needed" unless block

        # TODO: Find the signal module directly, then retrieve the info
        # from that, instead of vice versa.
        bldr = Builders::SignalBuilder.new(self)
        wrapped = bldr.build_class.from(block)
        FFI::Function.new rettype, argtypes, &wrapped
      end

      def arguments_to_gvalue_array instance, *rest
        arr = ::GObject::ValueArray.new self.n_args + 1

        arr.append GObject::Value.wrap_instance(instance)

        self.args.zip(rest).each do |info, arg|
          arr.append info.argument_type.make_g_value.set_value(arg)
        end

        arr
      end

      def gvalue_for_return_value
        GObject::Value.for_g_type return_type.g_type
      end

      # TODO: Rename and clarify relation to argument_ffi_types:
      # The types returned by ffi_callback_argument_types are more basic than
      # those returned by argument_ffi_types. Is there a way to make these
      # methods more related? Perhaps argument_ffi_types can return more basic
      # types as well?
      def ffi_callback_argument_types
        types = args.map do |arg|
          arg.argument_type.to_callback_ffitype
        end
        types.unshift(:pointer).push(:pointer)
      end

      def return_ffi_type
        result = super
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
