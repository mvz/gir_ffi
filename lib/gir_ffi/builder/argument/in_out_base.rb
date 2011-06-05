module GirFFI
  module Builder
    module Argument
      # Abstract base class implementing argument processing for arguments
      # with direction :inout.
      class InOutBase < Base
        def prepare
          @name = safe(@arginfo.name)
          @callarg = @function_builder.new_var
          @inarg = @name
          @retname = @function_builder.new_var
        end

        def cleanup
          ["GirFFI::ArgHelper.cleanup_ptr #{@callarg}" ]
        end
      end
    end
  end
end



