# frozen_string_literal: true

module GirFFI
  module Builders
    # Class builder that does nothing
    class NullClassBuilder
      def setup_method(_method)
        nil
      end

      def setup_instance_method(_method)
        nil
      end
    end
  end
end
