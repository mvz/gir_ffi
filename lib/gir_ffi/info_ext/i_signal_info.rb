module GirFFI
  module InfoExt
    module ISignalInfo
      # TODO: Generate cast back methods using existing Argument builders.
      def cast_back_signal_arguments *arguments
        instance = GirFFI::ArgHelper.object_pointer_to_object arguments.shift
        user_data = GirFFI::ArgHelper::OBJECT_STORE[arguments.pop.address]

        extra_arguments = self.args.zip(arguments).map do |info, arg|
          GObject::Helper.cast_signal_argument(info, arg)
        end

        return [instance, *extra_arguments].push user_data
      end
    end
  end
end

GObjectIntrospection::ISignalInfo.send :include, GirFFI::InfoExt::ISignalInfo
