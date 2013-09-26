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
        code = "def self.call_with_argument_mapping(#{method_arguments.join(', ')})"
        method_lines.each { |line| code << "\n  #{line}" }
        code << "\nend\n"
      end

      def method_lines
        lines = argument_builders.map(&:post).flatten +
          ["#{capture}_proc.call(#{call_arguments.join(', ')})"] +
          return_value_builder.post
        lines << "return #{return_value_builder.retval}" if return_value_builder.is_relevant?
        lines
      end

      def capture
        @capture ||= return_value_builder.is_relevant? ?
          "#{return_value_builder.callarg} = " :
          ""
      end

      def call_arguments
        @call_arguments ||= argument_builders.map(&:retval)
      end

      def method_arguments
        @method_arguments ||= argument_builders.map(&:callarg).unshift('_proc')
      end

      def return_value_builder
        @return_value_builder ||= ReturnValueBuilder.new(vargen, info.return_type)
      end

      def argument_builders
        unless defined?(@argument_builders)
          @argument_builders = argument_infos.map {|arg|
            # TODO: Make ReturnValueBuilder more generic
            # TODO: Make ReturnValueBuilder accept argument name
            ReturnValueBuilder.new vargen, arg.argument_type }
          argument_infos.each do |arg|
            if (idx = arg.closure) >= 0
              @argument_builders[idx].is_closure = true
            end
          end
        end
        @argument_builders
      end

      def argument_infos
        @argument_infos ||= info.args
      end

      def vargen
        @vargen ||= GirFFI::VariableNameGenerator.new
      end
    end
  end
end

