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

        info.args.each do |arg|
          if (idx = arg.closure) >= 0
            argument_builders[idx].is_closure = true
          end
        end

        method_arguments = argument_builders.map(&:callarg).unshift('_proc')
        call_arguments = argument_builders.map(&:retval)

        code = "def self.call_with_argument_mapping(#{method_arguments.join(', ')})"
        argument_builders.map(&:post).flatten.each do |line|
          code << "\n  #{line}"
        end
        capture = return_value_builder.is_relevant? ?
          "#{return_value_builder.callarg} = " :
          ""
        code << "\n  #{capture}_proc.call(#{call_arguments.join(', ')})"
        return_value_builder.post.each do |line|
          code << "\n  #{line}"
        end
        if return_value_builder.is_relevant?
          code << "\n  return #{return_value_builder.retval}"
        end
        code << "\nend\n"
        code
      end
    end
  end
end

