module GirFFI
  module Builder
    module Argument
      # Module implementing helper methods needed by List and SList
      # arguments.
      module ListBase
        private

        def elm_t
          subtype_tag.inspect
        end
      end
    end
  end
end

