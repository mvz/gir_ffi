# frozen_string_literal: true

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
      def wrap_in_closure(&block)
        bldr = Builders::SignalClosureBuilder.new(self)
        bldr.build_class.new(&block)
      end

      def arguments_to_gvalues(instance, arguments)
        arg_g_values = args.zip(arguments).map do |arg_info, arg|
          case arg_info.direction
          when :in
            type = arg_info.argument_type
            type.make_g_value.tap { |it| it.set_value arg }
          else
            raise NotImplementedError
          end
        end

        arg_g_values.unshift GObject::Value.wrap_instance(instance)
      end

      def gvalue_for_return_value
        return_type.make_g_value
      end
    end
  end
end

GObjectIntrospection::ISignalInfo.include GirFFI::InfoExt::ISignalInfo
