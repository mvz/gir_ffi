module GirFFI
  module Overrides
    module GObject

      def self.included(base)
	base.extend ClassMethods
      end

      module ClassMethods
	def type_from_instance_pointer inst_ptr
	  base = ::GObject::TypeInstance.new inst_ptr
	  kls = ::GObject::TypeClass.new(base[:g_class])
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

	# FIXME: This is a private helper function. Move elsewhere?
	def signal_callback_args klass, &block
	  return Proc.new do |instance, *args|
	    instance = klass.send :_real_new, instance
	    mapped = args.map {|arg|
	      if FFI::Pointer === arg
		begin
		  ObjectSpace._id2ref arg.address
		rescue RangeError
		  arg
		end
	      else
		arg
	      end
	    }
	    block.call(instance, *mapped)
	  end
	end

	def signal_emit object, signal, *args
	  type = type_from_instance object

	  id = signal_lookup signal, type

	  val = ::GObject::Value.new
	  val.init type
	  val.set_instance object

	  q = ::GObject::SignalQuery.new
	  signal_query id, q

	  use_ret = (q[:return_type] != ::GObject.type_from_name("void"))
	  if use_ret
	    rval = ::GObject::Value.new
	    rval.init q[:return_type]
	  end

	  arr = Helper.signal_arguments_to_gvalue_array signal, object, *args

	  signal_emitv arr[:values], id, 0, rval

	  if use_ret
	    rval
	  else
	    nil
	  end
	end

	def signal_connect object, signal, data=nil, &block
	  sig = object.class.gir_ffi_builder.find_signal signal
	  if sig.nil?
	    raise "Signal #{signal} is invalid for #{object}"
	  end

	  rettype = GirFFI::Builder.itypeinfo_to_ffitype sig.return_type

	  argtypes = [:pointer] + sig.args.map {|a| :pointer} + [:pointer]

	  callback = FFI::Function.new rettype, argtypes,
	    &(signal_callback_args(object.class, &block))

	  signal_connect_data object, signal, callback, data, nil, 0
	end
      end

      module Helper
	def self.signal_arguments_to_gvalue_array signal, instance, *rest
	  sig = instance.class.gir_ffi_builder.find_signal signal

	  arr = ::GObject::ValueArray.new sig.n_args+1

	  val = ::GObject::Value.new
	  val.init ::GObject.type_from_instance(instance)
	  val.set_instance instance
	  arr.append val
	  val.unset

	  sig.args.zip(rest).each do |a|
	    info, arg = *a
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

	      arr.append val

	      val.unset

	    else
	      raise NotImplementedError
	    end
	  end

	  arr
	end

	def self.cast_back_signal_arguments signalinfo, klass, *args
	  result = []

	  # Instance
	  instptr = args.shift
	  instance = klass.send :_real_new, instptr
	  result << instance

	  # Extra arguments
	  signalinfo.args.each do |info|
	    arg = args.shift
	    if info.type.tag == :interface
	      iface = info.type.interface
	      kls = GirFFI::Builder.build_class(iface.namespace, iface.name)
	      result << kls.send(:_real_new, arg)
	    else
	      result << arg
	    end
	  end

	  # User Data
	  result << args.shift

	  return result
	end
      end

    end
  end
end
