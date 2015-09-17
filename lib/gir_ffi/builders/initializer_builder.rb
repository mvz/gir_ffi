module GirFFI
  module Builders
    # Implements the creation of a Ruby object initializer definition out of a
    # GIR IFunctionInfo.
    class InitializerBuilder
      # Implements post-conversion for initializer functions
      class InitializerReturnValueBuilder < BaseArgumentBuilder
        def capture_variable_name
          @capture_variable_name ||= new_variable
        end

        def post_conversion
          ["store_pointer(#{capture_variable_name})"]
        end
      end

      def initialize info
        @info = info
        vargen = GirFFI::VariableNameGenerator.new
        @argument_builders = @info.args.map { |arg| ArgumentBuilder.new vargen, arg }
        return_value_info = ReturnValueInfo.new(@info.return_type,
                                                @info.caller_owns,
                                                @info.skip_return?)
        @return_value_builder = InitializerReturnValueBuilder.new(vargen,
                                                                  return_value_info)
        @argument_builder_collection = ArgumentBuilderCollection.new(
          @return_value_builder, @argument_builders,
          error_argument_builder: error_argument(vargen))
        @template = MethodTemplate.new(self, @argument_builder_collection)
      end

      def generate
        @template.method_definition
      end

      def singleton_method?
        false
      end

      def method_name
        @info.safe_name.sub(/^new/, 'initialize')
      end

      def method_arguments
        @argument_builder_collection.method_argument_names
      end

      def preparation
        []
      end

      def invocation
        "#{lib_name}.#{@info.symbol} #{function_call_arguments.join(', ')}"
      end

      def result
        []
      end

      private

      def lib_name
        "#{@info.safe_namespace}::Lib"
      end

      def error_argument vargen
        if @info.throws?
          ErrorArgumentBuilder.new vargen, ErrorArgumentInfo.new
        end
      end

      def function_call_arguments
        @argument_builder_collection.call_argument_names
      end
    end
  end
end
