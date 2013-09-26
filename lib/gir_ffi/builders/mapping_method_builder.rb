module GirFFI
  module Builders
    # Implements the creation mapping method for a callback or signal
    # handler. This method converts arguments from C to Ruby, and the
    # result from Ruby to C.
    class MappingMethodBuilder
      def initialize info
        @info = info
      end

      attr_reader :info

      def method_definition
        vargen = GirFFI::VariableNameGenerator.new
        argument_builders = info.args.map {|arg|
          # TODO: Make ReturnValueBuilder more generic
          # TODO: Make ReturnValueBuilder accept argument name
          ReturnValueBuilder.new vargen, arg.argument_type }

        return_value_builder = ReturnValueBuilder.new(vargen,
                                                      info.return_type)

        method_arguments = argument_builders.map(&:callarg).unshift('_proc')
        call_arguments = argument_builders.map(&:retval)

        code = "def self.call_with_argument_mapping(#{method_arguments.join(', ')})"
        capture = return_value_builder.is_relevant? ?
          "#{return_value_builder.callarg} = " :
          ""
        code << "\n  #{capture}_proc.call(#{call_arguments.join(', ')})"
        if return_value_builder.is_relevant?
          code << "\n  return #{return_value_builder.retval}"
        end
        code << "\nend\n"
        code
      end
    end
  end
end

