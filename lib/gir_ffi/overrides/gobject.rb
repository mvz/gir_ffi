module GirFFI
  module Overrides
    module GObject

      def self.included(base)
	base.extend ClassMethods
      end

      module ClassMethods
	def signal_emit object, signal
	  base = ::GObject::TypeInstance.new object.to_ptr
	  kls = ::GObject::TypeClass.new(base[:g_class])
	  type = kls[:g_type]
	  id = signal_lookup signal, type
	  val = ::GObject::Value.new
	  val.init type
	  val.set_instance object
	  signal_emitv val, id, 0, nil
	end

	def signal_connect object, signal, &block
	  callback = Proc.new(&block)
	  signal_connect_data object, signal, callback, nil, nil, 0
	end
      end

    end
  end
end
