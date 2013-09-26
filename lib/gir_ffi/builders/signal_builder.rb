require 'gir_ffi/builders/base_type_builder'

module GirFFI
  module Builders
    # Implements the creation of a signal module for handling a particular
    # signal. The type will be attached to the appropriate class.
    class SignalBuilder < BaseTypeBuilder
      def mapping_method_definition
        vargen = GirFFI::VariableNameGenerator.new
        argument_builders = @info.args.map {|arg|
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
