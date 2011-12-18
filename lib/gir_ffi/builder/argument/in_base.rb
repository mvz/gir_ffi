module GirFFI
  module Builder
    module Argument
      # Abstract base class implementing argument processing for arguments
      # with direction :in.
      class InBase < Base
        # FIXME: Make class work without 'prepare' stage.
        def prepare
          @inarg = @name
        end
      end
    end
  end
end

