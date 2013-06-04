module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::ISignalInfo needed by GirFFI
    # TODO: Rename methods to not include 'signal' everywhere.
    module ISignalInfo
      # Create a signal hander callback. Wraps the given block in such a way that
      # arguments and return value are cast correctly to the ruby world and back.
      #
      # @param  block   The body of the signal handler
      #
      # @return [FFI::Function] The signal handler, ready to be passed as a
      #   callback to C.
      def signal_callback &block
        rettype = Builder.ffi_callback_return_type self
        argtypes = Builder.ffi_callback_argument_types self

        # TODO: Create signal handler type?
        FFI::Function.new rettype, argtypes, &signal_callback_args(&block)
      end

      # TODO: Generate cast back methods using existing Argument builders.
      def cast_back_signal_arguments *arguments
        instance = GirFFI::ArgHelper.object_pointer_to_object arguments.shift
        user_data = GirFFI::ArgHelper::OBJECT_STORE[arguments.pop.address]

        extra_arguments = self.args.zip(arguments).map do |info, arg|
          info.cast_signal_argument(arg)
        end

        return [instance, *extra_arguments].push user_data
      end

      def signal_callback_args &block
        raise ArgumentError, "Block needed" unless block
        return Proc.new do |*args|
          mapped = cast_back_signal_arguments(*args)
          block.call(*mapped)
        end
      end

      def signal_arguments_to_gvalue_array instance, *rest
        arr = ::GObject::ValueArray.new self.n_args + 1

        arr.append GObject::Value.wrap_instance(instance)

        self.args.zip(rest).each do |info, arg|
          arr.append info.argument_type.make_g_value.set_value(arg)
        end

        arr
      end

      def gvalue_for_signal_return_value
        GObject::Value.for_g_type return_type.g_type
      end
    end
  end
end

GObjectIntrospection::ISignalInfo.send :include, GirFFI::InfoExt::ISignalInfo
