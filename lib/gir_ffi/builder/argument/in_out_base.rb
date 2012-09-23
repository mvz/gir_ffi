module GirFFI
  module Builder
    module Argument
      # Abstract base class implementing argument processing for arguments
      # with direction :inout.
      class InOutBase < Base
        def initialize var_gen, name, typeinfo, direction
          super var_gen, name, typeinfo, direction
          @inarg = @name
        end

        def retname
          @retname ||= @var_gen.new_var
        end
      end
    end
  end
end
