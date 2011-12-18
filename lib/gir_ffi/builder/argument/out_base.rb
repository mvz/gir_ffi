module GirFFI
  module Builder
    module Argument
      # Abstract base class implementing argument processing for arguments
      # with direction :out.
      class OutBase < Base
        def prepare
        end

        def retname
          @retname ||= @var_gen.new_var
        end
      end
    end
  end
end


