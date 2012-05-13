module GirFFI
  module CallbackHelper
    def self.wrap_in_callback_args_mapper namespace, name, prc
      return prc if FFI::Function === prc
      return nil if prc.nil?
      info = GObjectIntrospection::IRepository.default.find_by_name namespace, name
      return Proc.new do |*args|
	prc.call(*map_callback_args(args, info))
      end
    end

    def self.map_callback_args args, info
      args.zip(info.args).map { |arg, inf|
	map_single_callback_arg arg, inf.argument_type }
    end

    # TODO: Use GirFFI::ReturnValue classes for mapping.
    def self.map_single_callback_arg arg, type
      case type.tag
      when :interface
        map_interface_callback_arg arg, type
      when :utf8
	ArgHelper.ptr_to_utf8 arg
      when :void
        map_void_callback_arg arg
      when :array
	subtype = type.param_type(0)
        if subtype.tag == :interface and arg.is_a?(FFI::Pointer)
	  map_interface_callback_arg arg, subtype
	else
	  raise NotImplementedError
	end
      else
	arg
      end
    end

    def self.map_interface_callback_arg arg, type
      iface = type.interface
      case iface.info_type
      when :object, :interface
        arg.to_object
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
        GirFFI::ArgHelper::OBJECT_STORE[arg.address]
      end
    end
  end
end

