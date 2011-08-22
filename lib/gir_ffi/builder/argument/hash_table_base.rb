module GirFFI
  module Builder
    module Argument
      # Module implementing helper methods needed by HashTable arguments.
      module HashTableBase
        private

        def key_t
          subtype_tag(0).inspect
        end

        def val_t
          val_t = subtype_tag(1).inspect
        end
      end
    end
  end
end


