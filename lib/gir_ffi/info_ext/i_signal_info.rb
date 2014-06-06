module GirFFI
  module InfoExt
    # Extensions for GObjectIntrospection::ISignalInfo needed by GirFFI
    module ISignalInfo
      # Create a signal hander closure. Wraps the given block in a custom
      # descendent of RubyClosure with a marshaller tailored for this signal.
      #
      # @param  block   The body of the signal handler
      #
      # @return [GObject::RubyClosure]  The signal handler closure, ready to be
      #                                 passed as a GClosure to C.
      def wrap_in_closure &block
        bldr = Builders::SignalClosureBuilder.new(self)
        bldr.build_class.new(&block)
      end

      # TODO: Use argument info to convert out arguments and array lengths.
      def arguments_to_gvalues instance, arguments
        arg_values = self.args.zip(arguments).map do |info, arg|
          info.argument_type.make_g_value.set_value(arg)
        end

        arg_values.unshift GObject::Value.wrap_instance(instance)
      end

      def gvalue_for_return_value
        return_type.make_g_value
      end
    end
  end
end

GObjectIntrospection::ISignalInfo.send :include, GirFFI::InfoExt::ISignalInfo
