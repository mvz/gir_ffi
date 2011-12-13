module GirFFI
  # Generates method stubs that will replace themselves with the real
  # method upon being called.
  class MethodStubber
    def initialize method_info
      @info = method_info
    end

    def method_stub
      symbol = @info.name
      "
        def #{@info.method? ? '' : 'self.'}#{symbol} *args, &block
          setup_and_call :#{symbol}, *args, &block
        end
      "
    end
  end
end
