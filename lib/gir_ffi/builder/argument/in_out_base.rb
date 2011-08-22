module GirFFI
  module Builder
    module Argument
      # Abstract base class implementing argument processing for arguments
      # with direction :inout.
      class InOutBase < Base
        def prepare
          @name = safe(@arginfo.name)
          @inarg = @name
        end

        def callarg
          @callarg ||= @function_builder.new_var
        end

        def retname
          @retname ||= @function_builder.new_var
        end
      end
    end
  end
end



