module GirFFI
  module InfoExt
    module ISignalInfo
      # Create a signal hander callback. Wraps the given block in such a way that
      # arguments and return value are cast correctly to the ruby world and back.
      #
      # @param  block   The body of the signal handler
      #
      # @return [FFI::Function] The signal handler, ready to be passed as a
      #   callback to C.
      def signal_callback &block
        GirFFI::Builder.build_callback self, &signal_callback_args(&block)
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

        arr.append GObject::Helper.signal_reciever_to_gvalue instance

        self.args.zip(rest).each do |info, arg|
          arr.append GObject::Helper.signal_argument_to_gvalue info, arg
        end

        arr
      end

      def gvalue_for_signal_return_value
        GObject::Helper.gvalue_for_type_info return_type
      end
    end
  end
end

GObjectIntrospection::ISignalInfo.send :include, GirFFI::InfoExt::ISignalInfo
