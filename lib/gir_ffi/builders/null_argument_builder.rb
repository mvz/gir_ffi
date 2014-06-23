module GirFFI
  # Argument builder that does nothing. Implements the Null Object pattern.
  class NullArgumentBuilder
    def initialize *; end

    def pre_conversion; []; end

    def post; []; end

    def array_length_idx; -1; end

    def method_argument_name; nil; end

    def return_value_name; nil; end

    def callarg; end
  end
end
