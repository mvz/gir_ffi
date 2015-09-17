module GirFFI
  module Builders
    # Base class for method definition builders.
    class BaseMethodBuilder
      def vargen
        @vargen ||= GirFFI::VariableNameGenerator.new
      end
    end
  end
end
