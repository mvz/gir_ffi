module GirFFI
  # Generates a sequence of unique variable names used in generating
  # function definitions.
  class VariableNameGenerator
    def initialize
      @varno = 0
    end

    def new_var
      @varno += 1
      "_v#{@varno}"
    end
  end
end
