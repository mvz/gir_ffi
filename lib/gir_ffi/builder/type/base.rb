require 'gir_ffi/builder_helper'

module GirFFI
  module Builder
    module Type

      # Base class for type builders.
      class Base
        include BuilderHelper

        def initialize info
          @info = info
          @namespace = @info.namespace
          @classname = @info.safe_name
        end

        def build_class
          unless defined? @klass
            instantiate_class
          end
          @klass
        end

        attr_reader :info

        private

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

        def gir
          @gir ||= GObjectIntrospection::IRepository.default
        end
      end
    end
  end
end
