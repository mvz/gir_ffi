module GirFFI
  module Builder
    module Argument
      # Abstract base class implementing argument processing for arguments
      # with direction :in.
      class InBase < Base
        def prepare
          @name = safe(@arginfo.name)
          @inarg = @name
        end

        def callarg
          @callarg ||= @var_gen.new_var
        end
      end
    end
  end
end

