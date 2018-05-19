# frozen_string_literal: true

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
    class Struct < GirFFI::Struct
      layout :parent, Closure::Struct, 0,
             :block_id, :int64
    end

    def initialize(&block)
      raise ArgumentError unless block_given?

      initialize_simple(self.class::Struct.size, nil)
      self.block = block
      set_marshal proc { |*args| self.class.marshaller(*args) }
    end

    # @api private
    def self.marshaller(closure, return_value, param_values, _invocation_hint,
                        _marshal_data)
      # TODO: Improve by registering RubyClosure as a GObject type
      rclosure = wrap(closure.to_ptr)
      param_values ||= []

      args = param_values.map(&:get_value)

      result = rclosure.invoke_block(*args)

      return_value.set_value(result) if return_value
    end

    # @api private
    # TODO: Re-structure so invoke_block can become a private method
    def invoke_block(*args)
      block.call(*args)
    end

    private

    # @api private
    def block=(block)
      id = block.object_id
      BLOCK_STORE[id] = block
      @struct[:block_id] = id
    end

    def block
      BLOCK_STORE[@struct[:block_id]]
    end
  end
end
