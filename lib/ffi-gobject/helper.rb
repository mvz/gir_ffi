module GObject
  module Helper
    # Create a signal hander callback. Wraps the given block in such a way that
    # arguments and return value are cast correctly to the ruby world and back.
    #
    # @param  klass   The class of the object that will receive the signal.
    # @param  signal  The name of the signal
    # @param  block   The body of the signal handler
    #
    # @return [FFI::Function] The signal handler, ready to be passed as a
    #   callback to C.
    def self.signal_callback klass, signal, &block
      sig_info = klass.find_signal signal

      callback_block = sig_info.signal_callback_args(&block)

      builder.build_callback sig_info, &callback_block
    end

    def self.builder= bldr
      @builder = bldr
    end

    def self.builder
      @builder ||= GirFFI::Builder
    end

    def self.signal_arguments_to_gvalue_array signal, instance, *rest
      sig = instance.class.find_signal signal

      arr = ::GObject::ValueArray.new sig.n_args + 1

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
      val = gvalue_for_type_info info.argument_type
      val.set_value arg
    end

    def self.gvalue_for_type_info info
      tag = info.tag
      gtype = case tag
              when :interface
                info.interface.g_type
              when :void
                return nil
              else
                TYPE_TAG_TO_GTYPE[tag]
              end
      raise "GType not found for type info with tag #{tag}" unless gtype
      Value.new.tap {|val| val.init gtype}
    end

    def self.gvalue_for_signal_return_value signal, object
      sig = object.class.find_signal signal
      rettypeinfo = sig.return_type

      gvalue_for_type_info rettypeinfo
    end
  end
end
