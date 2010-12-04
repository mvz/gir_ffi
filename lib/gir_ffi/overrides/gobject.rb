module GirFFI
  module Overrides
    module GObject

      def self.included(base)
	base.extend ClassMethods
      end

      module ClassMethods
	def type_from_instance instance
	  base = ::GObject::TypeInstance.new instance.to_ptr
	  kls = ::GObject::TypeClass.new(base[:g_class])
	  kls[:g_type]
	end

	def signal_emit object, signal
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

	  signal_emitv val, id, 0, rval

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

	  callback = FFI::Function.new :void, [:pointer, :pointer],
	    &GirFFI::ArgHelper.mapped_callback_args(&block)

	  signal_connect_data object, signal, callback, data, nil, 0
	end
      end

    end
  end
end
