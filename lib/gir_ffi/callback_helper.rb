module GirFFI
  module CallbackHelper
    def self.wrap_in_callback_args_mapper namespace, name, prc
      return prc if FFI::Function === prc
      return nil if prc.nil?
      info = IRepository.default.find_by_name namespace, name
      return Proc.new do |*args|
	prc.call(*map_callback_args(args, info))
      end
    end

    def self.map_callback_args args, info
      args.zip(info.args).map { |arg, inf|
	map_single_callback_arg arg, inf }
    end

    # TODO: Use GirFFI::ReturnValue classes for mapping.
    def self.map_single_callback_arg arg, info
      case info.argument_type.tag
      when :interface
        map_interface_callback_arg arg, info
      when :utf8
	ArgHelper.ptr_to_utf8 arg
      when :void
        map_void_callback_arg arg
      else
	arg
      end
    end

    def self.map_interface_callback_arg arg, info
      iface = info.argument_type.interface
      case iface.info_type
      when :object
        ArgHelper.object_pointer_to_object arg
      when :struct
        klass = GirFFI::Builder.build_class iface
        klass.wrap arg
      else
        arg
      end
    end

    def self.map_void_callback_arg arg
      if arg.null?
        nil
      else
        begin
          # TODO: Use custom object store.
          ObjectSpace._id2ref arg.address
        rescue RangeError
          arg
        end
      end
    end
  end
end

