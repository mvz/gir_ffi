require 'gir_ffi/builders/base_type_builder'
require 'gir_ffi/callback_base'

module GirFFI
  module Builders
    # Implements the creation of a callback type. The type will be
    # attached to the appropriate namespace module, and will be defined
    # as a callback for FFI.
    class CallbackBuilder < BaseTypeBuilder
      def instantiate_class
        @klass ||= get_or_define_class namespace_module, @classname, CallbackBase
        @callback ||= optionally_define_constant @klass, :Callback do
          lib.callback callback_sym, argument_types, return_type
        end
        setup_constants unless already_set_up
        @klass
      end

      def mapping_method_definition
        vargen = GirFFI::VariableNameGenerator.new
        argument_builders = @info.args.map {|arg|
          # TODO: Make ReturnValueBuilder more generic
          # TODO: Make ReturnValueBuilder accept argument name
          ReturnValueBuilder.new vargen, arg.argument_type }

        return_value_builder = ReturnValueBuilder.new(vargen,
                                                      info.return_type)

        @info.args.each do |arg|
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
      end

      def callback_sym
        @classname.to_sym
      end

      def argument_types
        @info.argument_ffi_types
      end

      def return_type
        @info.return_ffi_type
      end
    end
  end
end
