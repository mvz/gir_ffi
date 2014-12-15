require 'ffi-gobject/closure'

module GObject
  # This class encapsulates Ruby
  # blocks as GObject Closures.
  class RubyClosure < Closure
    BLOCK_STORE = {}

    # Extend the standard GClosure layout with a field block_id to store
    # the object_id of the associated block.
    class Struct < FFI::Struct
      layout :parent, Closure::Struct, 0,
             :block_id, :int64
    end

    def block
      BLOCK_STORE[@struct[:block_id]]
    end

    def block= block
      id = block.object_id
      BLOCK_STORE[id] = block
      @struct[:block_id] = id
    end

    def invoke_block *args
      block.call(*args)
    end

    def self.new &block
      raise ArgumentError unless block_given?

      closure = wrap(new_simple(self::Struct.size, nil).to_ptr)
      closure.block = block
      closure.set_marshal proc { |*args| marshaller(*args) }

      closure
    end

    def self.marshaller closure, return_value, param_values, _invocation_hint, _marshal_data
      # TODO: Improve by registering RubyClosure as a GObject type
      rclosure = wrap(closure.to_ptr)
      param_values ||= []

      args = param_values.map(&:get_value)

      result = rclosure.invoke_block(*args)

      return_value.set_ruby_value(result) if return_value
    end
  end
end
