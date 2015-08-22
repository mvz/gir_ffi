require 'ffi-gobject/closure'

module GObject
  # Encapsulates Ruby blocks as GObject Closures.
  class RubyClosure < Closure
    # @api private
    BLOCK_STORE = {}

    # Extend the standard +GObject::Closure+ layout with a field block_id to store
    # the object_id of the associated block.
    #
    # @api private
    class Struct < FFI::Struct
      layout :parent, Closure::Struct, 0,
             :block_id, :int64
    end

    def self.new &block
      raise ArgumentError unless block_given?

      closure = wrap(new_simple(self::Struct.size, nil).to_ptr)
      closure.block = block
      closure.set_marshal proc { |*args| marshaller(*args) }

      closure
    end

    # @api private
    def self.marshaller closure, return_value, param_values, _invocation_hint, _marshal_data
      # TODO: Improve by registering RubyClosure as a GObject type
      rclosure = wrap(closure.to_ptr)
      param_values ||= []

      args = param_values.map(&:get_value)

      result = rclosure.invoke_block(*args)

      return_value.set_ruby_value(result) if return_value
    end

    # @api private
    # TODO: Re-structure so block= and invoke_block can become private methods
    def block= block
      id = block.object_id
      BLOCK_STORE[id] = block
      @struct[:block_id] = id
    end

    # @api private
    def invoke_block *args
      block.call(*args)
    end

    private

    def block
      BLOCK_STORE[@struct[:block_id]]
    end
  end
end
