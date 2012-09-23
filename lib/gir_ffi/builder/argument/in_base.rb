module GirFFI
  module Builder
    module Argument
      # Abstract base class implementing argument processing for arguments
      # with direction :in.
      class InBase < Base
        def initialize var_gen, name, typeinfo, direction
          super var_gen, name, typeinfo, direction
          @inarg = @name
        end
      end
    end
  end
end
