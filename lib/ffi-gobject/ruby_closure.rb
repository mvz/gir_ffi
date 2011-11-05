require 'ffi-gobject/closure'

module GObject
  # This class encapsulates Ruby
  # blocks as GObject Closures.
  class RubyClosure < Closure
    BLOCK_STORE = {}

    # Extend the standard GClosure layout with a field blockhash to store
    # the object_id of the associated block.
    class Struct < FFI::Struct
      layout :parent, Closure::Struct, 0,
        :blockhash, :int64
    end

    def block
      self.class::BLOCK_STORE[self[:blockhash]]
    end

    def invoke_block *args
      block.call(*args)
    end

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
  end
end
