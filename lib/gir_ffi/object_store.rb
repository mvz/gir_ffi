# frozen_string_literal: true

module GirFFI
  # Helper class for storing objects for later retrieval. Used to store user
  # data arguments.
  class ObjectStore
    def initialize
      @store = {}
    end

    def store(obj)
      return FFI::Pointer::NULL if obj.nil?
      # FIXME: Don't use object_id!
      key = obj.object_id
      @store[key] = obj
      FFI::Pointer.new(key)
    end

    def fetch(ptr)
      return if ptr.null?
      key = ptr.address
      if @store.key? key
        @store[key]
      else
        ptr
      end
    end
  end
end
