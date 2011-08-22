module GirFFI
  module Builder
    module Argument
      # Abstract base class implementing argument processing for arguments
      # with direction :out.
      class OutBase < Base
        def prepare
          @name = safe(@arginfo.name)
        end

        def callarg
          @callarg ||= @function_builder.new_var
        end

        def retname
          @retname ||= @function_builder.new_var
        end

        def pre
          [ "#{callarg} = GirFFI::InOutPointer.for #{base_type.inspect}" ]
        end
      end
    end
  end
end


