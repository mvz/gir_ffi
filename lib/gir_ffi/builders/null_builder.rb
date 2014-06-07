module GirFFI
  # Object Builder that does nothing. Implements the Null Object pattern.
  class NullBuilder
    def find_signal _
      nil
    end

    def find_property _
      nil
    end
  end
end
