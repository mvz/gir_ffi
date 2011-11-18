module GirFFI
  module Builder
    module Argument
      # Abstract base class implementing argument processing for arguments
      # with direction :inout.
      class InOutBase < Base
        def prepare
          @inarg = @name
        end

        def callarg
          @callarg ||= @var_gen.new_var
        end

        def retname
          @retname ||= @var_gen.new_var
        end
      end
    end
  end
end



