module GirFFI
  # Argument builder that does nothing. Implements the Null Object pattern.
  class NullArgumentBuilder
    def initialize(*)
    end

    def pre_conversion
      []
    end

    def post_conversion
      []
    end

    def array_length_idx
      -1
    end

    def method_argument_name
      nil
    end

    def return_value_name
      nil
    end

    def call_argument_name
      nil
    end

    def capture_variable_name
      nil
    end

    def closure_idx
      -1
    end

    def block_argument?
      false
    end

    def post_converted_name
      nil
    end
  end
end
