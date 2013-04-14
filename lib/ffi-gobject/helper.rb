module GObject
  module Helper
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
      gtype = info.g_type
      return nil if gtype == TYPE_NONE
      Value.new.tap {|val| val.init gtype}
    end

    def self.gvalue_for_signal_return_value signal, object
      sig = object.class.find_signal signal
      rettypeinfo = sig.return_type

      gvalue_for_type_info rettypeinfo
    end
  end
end
