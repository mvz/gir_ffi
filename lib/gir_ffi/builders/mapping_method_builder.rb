require 'gir_ffi/builders/callback_argument_builder'
require 'gir_ffi/builders/callback_return_value_builder'

module GirFFI
  module Builders
    class Foo
      attr_reader :return_value_builder
      attr_reader :vargen
      attr_reader :argument_builders

      def initialize return_value_builder, vargen, argument_builders
        @vargen = vargen
        @argument_builders = argument_builders
        @return_value_builder = return_value_builder
      end

      def parameter_preparation
        argument_builders.sort_by.with_index {|arg, i|
          [arg.type_info.array_length, i] }.map(&:pre_conversion).flatten
      end

      def return_value_conversion
        all_builders.map(&:post_conversion).flatten
      end

      def capture_variable_names
        @capture_variable_names ||=
          all_builders.map(&:capture_variable_name).compact
      end

      def call_argument_names
        @call_argument_names ||= argument_builders.map(&:call_argument_name).compact
      end

      def method_argument_names
        @method_argument_names ||= argument_builders.map(&:method_argument_name)
      end

      def return_value_name
        return_value_builder.return_value_name if return_value_builder.is_relevant?
      end

      def self.set_up_argument_relations argument_infos, argument_builders
        argument_infos.each do |arg|
          if (idx = arg.closure) >= 0
            argument_builders[idx].is_closure = true
          end
        end
        argument_builders.each do |bldr|
          if (idx = bldr.array_length_idx) >= 0
            other = argument_builders[idx]

            bldr.length_arg = other
            other.array_arg = bldr
          end
        end
      end

      private

      def all_builders
        @all_builders ||= [return_value_builder] + argument_builders
      end
    end

    # Implements the creation mapping method for a callback or signal
    # handler. This method converts arguments from C to Ruby, and the
    # result from Ruby to C.
    class MappingMethodBuilder
      def self.for_callback argument_infos, return_type_info
        vargen = VariableNameGenerator.new

        argument_builders = argument_infos.map {|arg|
          CallbackArgumentBuilder.new vargen, arg }
        return_value_info = ReturnValueInfo.new(return_type_info)
        return_value_builder = CallbackReturnValueBuilder.new(vargen, return_value_info)

        Foo.set_up_argument_relations argument_infos, argument_builders
        foo = Foo.new return_value_builder, vargen, argument_builders
        new return_value_builder, argument_builders, foo
      end

      def self.for_vfunc receiver_info, argument_infos, return_type_info
        vargen = VariableNameGenerator.new

        receiver_builder = CallbackArgumentBuilder.new vargen, receiver_info
        argument_builders = argument_infos.map {|arg|
          CallbackArgumentBuilder.new vargen, arg }
        return_value_info = ReturnValueInfo.new(return_type_info)
        return_value_builder = CallbackReturnValueBuilder.new(vargen, return_value_info)

        Foo.set_up_argument_relations argument_infos, argument_builders

        argument_builders.unshift receiver_builder
        foo = Foo.new return_value_builder, vargen, argument_builders

        new return_value_builder, argument_builders, foo
      end

      def initialize return_value_builder, argument_builders, foo
        @argument_builders = argument_builders
        @return_value_builder = return_value_builder
        @foo = foo
      end

      attr_reader :return_value_builder
      attr_reader :argument_builders

      def method_definition
        code = "def self.call_with_argument_mapping(#{method_arguments.join(', ')})"
        method_lines.each { |line| code << "\n  #{line}" }
        code << "\nend\n"
      end

      def method_lines
        @foo.parameter_preparation +
          call_to_proc +
          @foo.return_value_conversion +
          return_value
      end

      def return_value
        if (name = @foo.return_value_name)
          ["return #{name}"]
        else
          []
        end
      end

      def call_to_proc
        ["#{capture}_proc.call(#{@foo.call_argument_names.join(', ')})"]
      end

      def capture
        @capture ||= begin
                       names = @foo.capture_variable_names
                       names.any? ? "#{names.join(", ")} = " : ""
                     end
      end

      def method_arguments
        @method_arguments ||= @foo.method_argument_names.dup.unshift('_proc')
      end
    end
  end
end
