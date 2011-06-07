module GirFFI
  module Overrides
    module GObject

      def self.included base
	base.extend ClassMethods
        extend_classes(base)
        attach_non_introspectable_functions(base)
        build_extra_classes(base)
      end

      def self.extend_classes base
        base::InitiallyUnowned.extend InitiallyUnownedClassMethods
        base::Value.class_eval {
          include ValueInstanceMethods
          extend ValueClassMethods
        }
        base::Closure.class_eval {
          include ClosureInstanceMethods
        }
      end

      def self.attach_non_introspectable_functions base
        base::Lib.attach_function :g_signal_connect_data,
          [:pointer, :string, base::Callback, :pointer, base::ClosureNotify,
            base::ConnectFlags],
            :ulong
        base::Lib.attach_function :g_closure_set_marshal,
          [:pointer, base::ClosureMarshal], :void
      end

      def self.build_extra_classes base
        build_ruby_closure_class base
      end

      # Build the GObject::RubyClosure class. This class encapsulates Ruby
      # blocks as GObject Closures.
      def self.build_ruby_closure_class base
        klass = Class.new(base::Closure) do
          const_set :BLOCK_STORE, {}

          const_set :Struct, Class.new(FFI::Struct) {
            layout :parent, base::Closure::Struct, 0,
            :blockhash, :int64
          }

          def self.new &block
            raise ArgumentError unless block_given?
            wrap(new_simple(self::Struct.size, nil).to_ptr).tap do |it|
              h = block.object_id
              self::BLOCK_STORE[h] = block
              it[:blockhash] = h
              it.set_marshal Proc.new {|*args| marshaller(*args)}
            end
          end

          def self.marshaller(closure, return_value, n_param_values,
                              param_values, invocation_hint, marshal_data)
            rclosure = self.wrap(closure.to_ptr)

            args = []
            n_param_values.times {|i|
              gv = ::GObject::Value.wrap(param_values.to_ptr +
                                         i * ::GObject::Value::Struct.size)
              args << gv.ruby_value
            }

            r = rclosure.invoke_block(*args)
            return_value.set_ruby_value r unless return_value.nil?
          end

          def block
            self.class::BLOCK_STORE[self[:blockhash]]
          end

          def invoke_block *args
            block.call(*args)
          end
        end
        base.const_set :RubyClosure, klass
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
        TAG_TYPE_TO_GTYPE_NAME_MAP = {
          :utf8 => "gchararray"
        }

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
          arg_type = info.argument_type
          tag = arg_type.tag

	  if tag == :interface
	    interface = info.argument_type.interface

	    val = ::GObject::Value.new
	    val.init info.argument_type.interface.g_type
	    case interface.info_type
	    when :struct
	      val.set_boxed arg
	    when :object
	      val.set_instance arg
	    else
	      raise NotImplementedError, interface.info_type
	    end

	    return val
	  else
            val = ::GObject::Value.new
            val.init ::GObject.type_from_name(TAG_TYPE_TO_GTYPE_NAME_MAP[tag])
            val.set_ruby_value arg
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

        # TODO: Generate cast back methods using existing Argument builders.
	def self.cast_back_signal_arguments signalinfo, klass, *args
	  result = []

	  # Instance
	  instptr = args.shift
	  instance = klass.wrap instptr
	  result << instance

	  # Extra arguments
	  signalinfo.args.each do |info|
            result << cast_signal_argument(info, args.shift)
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

        def self.cast_signal_argument info, arg
          arg_t = info.argument_type
          if arg_t.tag == :interface
            iface = arg_t.interface
            kls = GirFFI::Builder.build_class iface
            case iface.info_type
            when :enum, :flags
              kls[arg]
            else
              kls.wrap(arg)
            end
          else
            arg
          end
        end
      end

      module InitiallyUnownedClassMethods
        def constructor_wrap ptr
          super.tap {|obj| GirFFI::GObject.object_ref_sink obj}
        end
      end

      module ValueClassMethods
        def wrap_ruby_value val
          self.new.set_ruby_value val
        end
      end

      module ValueInstanceMethods
        def set_ruby_value val
          if current_gtype == 0
            init_for_ruby_value val
          end

	  case current_gtype_name
	  when "gboolean"
	    set_boolean val
          when "gint"
	    set_int val
	  when "gchararray"
	    set_string val
	  else
	    nil
	  end
          self
        end

        def init_for_ruby_value val
	  case val
	  when true, false
	    init ::GObject.type_from_name("gboolean")
          when Integer
	    init ::GObject.type_from_name("gint")
	  end
          self
        end

        def current_gtype
          self[:g_type]
        end

        def current_gtype_name
          ::GObject.type_name current_gtype
        end

        def ruby_value
	  case current_gtype_name.to_sym
	  when :gboolean
	    get_boolean
	  when :gint
	    get_int
          when :gchararray
            get_string
          when :GDate
            ::GLib::Date.wrap(get_boxed)
          when :GStrv
            ArgHelper.strv_to_utf8_array get_boxed
	  else
	    nil
	  end
        end
      end

      module ClosureInstanceMethods
        def set_marshal marshal
	  _v1 = GirFFI::ArgHelper.wrap_in_callback_args_mapper(
            "GObject", "ClosureMarshal", marshal)
	  ::GObject::Lib::CALLBACKS << _v1
	  ::GObject::Lib.g_closure_set_marshal self, _v1
        end
      end
    end
  end
end
