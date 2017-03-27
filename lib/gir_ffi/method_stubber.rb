# frozen_string_literal: true

module GirFFI
  # Generates method stubs that will replace themselves with the real
  # method upon being called.
  class MethodStubber
    def initialize(method_info)
      @info = method_info
    end

    def method_stub
      <<-STUB.reset_indentation
        def #{@info.method? ? '' : 'self.'}#{@info.safe_name} *args, &block
          setup_and_call "#{@info.name}", args, &block
        end
      STUB
    end
  end
end
