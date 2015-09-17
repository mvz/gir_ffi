module GirFFI
  module Builders
    # Base class for method definition builders.
    class BaseMethodBuilder
      def vargen
        @vargen ||= GirFFI::VariableNameGenerator.new
      end

      def argument_builders
        @argument_builders ||= @info.args.map { |arg| ArgumentBuilder.new vargen, arg }
      end
    end
  end
end
