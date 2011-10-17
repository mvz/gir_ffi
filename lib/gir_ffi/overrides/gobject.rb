module GirFFI
  module Overrides
    module GObject

      def self.included base
	base.extend ClassMethods
        extend_classes(base)
        preload_methods(base)
        build_extra_classes(base)
      end

      def self.extend_classes base
        base::Closure.class_eval {
          include ClosureInstanceMethods
        }
      end

      def self.preload_methods base
        base._setup_method :signal_emitv
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
	def type_from_instance instance
	  type_from_instance_pointer instance.to_ptr
	end

	def signal_emit object, signal, *args
	  type = type_from_instance object
	  id = signal_lookup signal, type

	  arr = Helper.signal_arguments_to_gvalue_array signal, object, *args
	  rval = Helper.gvalue_for_signal_return_value signal, object

	  ::GObject::Lib.g_signal_emitv arr[:values], id, 0, rval

	  rval
	end

	def signal_connect object, signal, data=nil, &block
	  sig = object.class._find_signal signal
	  if sig.nil?
	    raise "Signal #{signal} is invalid for #{object}"
	  end
	  if block.nil?
	    raise ArgumentError, "Block needed"
	  end

	  rettype = GirFFI::Builder.itypeinfo_to_ffitype sig.return_type

	  argtypes = GirFFI::Builder.ffi_argument_types_for_signal sig

	  callback = FFI::Function.new rettype, argtypes,
	    &(Helper.signal_callback_args(sig, object.class, &block))
          ::GObject::Lib::CALLBACKS << callback

          data_ptr = GirFFI::ArgHelper.object_to_inptr data

	  ::GObject::Lib.g_signal_connect_data object, signal, callback, data_ptr, nil, 0
	end
      end

      module Helper
        TAG_TYPE_TO_GTYPE_NAME_MAP = {
          :utf8 => "gchararray",
          :gboolean => "gboolean",
          :void => "void"
        }

	def self.signal_callback_args sig, klass, &block
	  return Proc.new do |*args|
	    mapped = cast_back_signal_arguments sig, klass, *args
	    block.call(*mapped)
	  end
	end

	def self.signal_arguments_to_gvalue_array signal, instance, *rest
	  sig = instance.class._find_signal signal

	  arr = ::GObject::ValueArray.new sig.n_args+1

          arr.append signal_reciever_to_gvalue instance

	  sig.args.zip(rest).each do |info, arg|
	    arr.append signal_argument_to_gvalue info, arg
	  end

	  arr
	end

        def self.signal_reciever_to_gvalue instance
          val = ::GObject::Value.new
          val.init ::GObject.type_from_instance instance
          val.set_instance instance
          return val
        end

	def self.signal_argument_to_gvalue info, arg
          arg_type = info.argument_type

          val = gvalue_for_type_info arg_type

	  if arg_type.tag == :interface
	    interface = arg_type.interface
	    case interface.info_type
	    when :struct
	      val.set_boxed arg
	    when :object
	      val.set_instance arg
            when :enum
              val.set_enum arg
	    else
	      raise NotImplementedError, interface.info_type
	    end
	  else
            val.set_ruby_value arg
	  end

          return val
	end

        def self.gvalue_for_type_info info
          tag = info.tag
          gtype = case tag
                  when :interface
                    info.interface.g_type
                  when :void
                    return nil
                  else
                    ::GObject.type_from_name(TAG_TYPE_TO_GTYPE_NAME_MAP[tag])
                  end
          ::GObject::Value.new.tap {|val| val.init gtype}
        end

	def self.gvalue_for_signal_return_value signal, object
          sig = object.class._find_signal signal
          rettypeinfo = sig.return_type

          gvalue_for_type_info rettypeinfo
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
          arg = GirFFI::ArgHelper::OBJECT_STORE[arg.address]
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

      module ClosureInstanceMethods
        def set_marshal marshal
	  _v1 = GirFFI::CallbackHelper.wrap_in_callback_args_mapper(
            "GObject", "ClosureMarshal", marshal)
	  ::GObject::Lib::CALLBACKS << _v1
	  ::GObject::Lib.g_closure_set_marshal self, _v1
        end
      end
    end
  end
end
