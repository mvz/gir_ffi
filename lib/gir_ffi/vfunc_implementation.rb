module GirFFI
  class VFuncImplementation
    attr_reader :name, :implementation

    def initialize name, implementation
      @name = name
      @implementation = implementation
    end
  end
end
