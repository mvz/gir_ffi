module GirFFI
  # Helper class for storing objects for later retrieval. Used to store user
  # data arguments.
  class ObjectStore
    def initialize
      @store = {}
    end

    def store(ptr, obj)
      @store[ptr.address] = obj
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
