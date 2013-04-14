module GirFFI
  module InfoExt
    module IArgInfo
      def cast_signal_argument arg
        arg_t = self.argument_type
        if arg_t.tag == :interface
          iface = arg_t.interface
          kls = GirFFI::Builder.build_class iface
          case iface.info_type
          when :enum, :flags
            kls[arg]
          when :interface
            arg.to_object
          else
            kls.wrap(arg)
          end
        else
          arg
        end
      end
    end
  end
end

GObjectIntrospection::IArgInfo.send :include, GirFFI::InfoExt::IArgInfo

