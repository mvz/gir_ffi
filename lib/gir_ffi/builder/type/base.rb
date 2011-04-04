module GirFFI
  module Builder
    module Type
      class Base
        include BuilderHelper

        def initialize info
          @info = info
          @namespace = @info.namespace
          @classname = @info.name.gsub(/^(.)/) { $1.upcase }
        end

        private

        def info
          @info
        end

        def namespace_module
          @namespace_module ||= Builder.build_module @namespace
        end

        def lib
          @lib ||= namespace_module.const_get :Lib
        end

        def get_or_define_class namespace, name, parent
          optionally_define_constant(namespace, name) {
            Class.new parent
          }
        end
      end
    end
  end
end
