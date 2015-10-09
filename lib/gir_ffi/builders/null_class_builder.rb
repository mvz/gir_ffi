module GirFFI
  module Builders
    class NullClassBuilder
      def setup_method(_)
        nil
      end

      def setup_instance_method(_)
        nil
      end
    end
  end
end
