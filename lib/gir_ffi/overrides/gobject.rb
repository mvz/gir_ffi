module GirFFI
  module Overrides
    module GObject

      def self.included(base)
	base.extend ClassMethods
        base::InitiallyUnowned.extend InitiallyUnownedClassMethods
        base::Lib.attach_function :g_signal_connect_data,
          [:pointer, :string, base::Callback, :pointer, base::ClosureNotify,
            base::ConnectFlags],
          :ulong
      end

      module ClassMethods
	# FIXME: These four helper methods belong elsewhere.
	def type_from_instance_pointer inst_ptr
	  base = ::GObject::TypeInstance.wrap inst_ptr
	  kls = ::GObject::TypeClass.wrap(base[:g_class])
	  kls[:g_type]
	end

	def type_from_instance instance
	  type_from_instance_pointer instance.to_ptr
	end

	def wrap_in_g_value val
	  gvalue = ::GObject::Value.new
	  case val
	  when true, false
	    gvalue.init ::GObject.type_from_name("gboolean")
	    gvalue.set_boolean val
	  else
	    nil
	  end
	  gvalue
	end

	def unwrap_g_value gvalue
	  gtype = gvalue[:g_type]
	  gtypename = ::GObject.type_name gtype
	  case gtypename
	  when "gboolean"
	    gvalue.get_boolean
	  else
	    nil
	  end
	end

	def signal_emit object, signal, *args
	  type = type_from_instance object
	  id = signal_lookup signal, type

	  arr = Helper.signal_arguments_to_gvalue_array signal, object, *args
	  rval = Helper.gvalue_for_signal_return_value signal, object

	  signal_emitv arr[:values], id, 0, rval

	  rval
	end

	def signal_connect object, signal, data=nil, &block
	  sig = object.class.gir_ffi_builder.find_signal signal
	  if sig.nil?
	    raise "Signal #{signal} is invalid for #{object}"
	  end
	  if block.nil?
	    raise ArgumentError, "Block needed"
	  end

	  rettype = GirFFI::Builder.itypeinfo_to_ffitype sig.return_type

          # FIXME: Why are these all pointers?
	  argtypes = [:pointer] + sig.args.map {|arg| :pointer} + [:pointer]

	  callback = FFI::Function.new rettype, argtypes,
	    &(Helper.signal_callback_args(sig, object.class, &block))
          ::GObject::Lib::CALLBACKS << callback

          data_ptr = GirFFI::ArgHelper.object_to_inptr data

	  ::GObject::Lib.g_signal_connect_data object, signal, callback, data_ptr, nil, 0
	end
      end

      module Helper
	def self.signal_callback_args sig, klass, &block
	  return Proc.new do |*args|
	    mapped = cast_back_signal_arguments sig, klass, *args
	    block.call(*mapped)
	  end
	end

	def self.signal_arguments_to_gvalue_array signal, instance, *rest
	  sig = instance.class.gir_ffi_builder.find_signal signal

	  arr = ::GObject::ValueArray.new sig.n_args+1

	  val = ::GObject::Value.new
	  val.init ::GObject.type_from_instance(instance)
	  val.set_instance instance
	  arr.append val
	  val.unset

	  sig.args.zip(rest).each do |info, arg|
	    arr.append signal_argument_to_gvalue info, arg
	  end

	  arr
	end
	
	def self.signal_argument_to_gvalue info, arg
	  if info.type.tag == :interface
	    interface = info.type.interface

	    val = ::GObject::Value.new
	    val.init info.type.interface.g_type
	    case interface.type
	    when :struct
	      val.set_boxed arg
	    when :object
	      val.set_instance arg
	    else
	      raise NotImplementedError, interface.type
	    end

	    return val
	  else
	    raise NotImplementedError
	  end
	end

	def self.gvalue_for_signal_return_value signal, object
	  type = ::GObject.type_from_instance object

	  # TODO: Use same signal info as signal_arguments_to_gvalue_array
	  id = ::GObject.signal_lookup signal, type

	  query = ::GObject::SignalQuery.new
	  ::GObject.signal_query id, query

	  use_ret = (query[:return_type] != ::GObject.type_from_name("void"))
	  if use_ret
	    rval = ::GObject::Value.new
	    rval.init query[:return_type]
	  end
	  rval
	end

	def self.cast_back_signal_arguments signalinfo, klass, *args
	  result = []

	  # Instance
	  instptr = args.shift
	  instance = klass.wrap instptr
	  result << instance

	  # Extra arguments
	  signalinfo.args.each do |info|
	    arg = args.shift
	    if info.type.tag == :interface
	      iface = info.type.interface
	      kls = GirFFI::Builder.build_class(iface.namespace, iface.name)
	      result << kls.wrap(arg)
	    else
	      result << arg
	    end
	  end

	  # User Data
	  arg = args.shift
	  arg = if FFI::Pointer === arg
		  begin
		    ObjectSpace._id2ref arg.address
		  rescue RangeError
		    arg
		  end
		else
		  arg
		end
	  result << arg

	  return result
	end
      end

      module InitiallyUnownedClassMethods
        def constructor_wrap ptr
          super.tap {|obj| GirFFI::GObject.object_ref_sink obj}
        end
      end

    end
  end
end
