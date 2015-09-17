module GirFFI
  module Builders
    # Abstract parent class of the argument building classes. These
    # classes are used by FunctionBuilder to create the code that
    # processes each argument before and after the actual function call.
    class BaseArgumentBuilder
      KEYWORDS = %w(
        alias and begin break case class def do
        else elsif end ensure false for if in
        module next nil not or redo rescue retry
        return self super then true undef unless
        until when while yield
      )

      attr_reader :arginfo
      attr_accessor :length_arg, :array_arg

      # TODO: closure unfortunately means two things in GLib: a closure
      # argument (user_data), and the Closure class (a callable object). Make
      # the distinction more explicit in GirFFI.
      def closure?
        @is_closure
      end

      def closure=(arg)
        @is_closure = arg
      end

      def initialize(var_gen, arginfo)
        @var_gen = var_gen
        @arginfo = arginfo
        @length_arg = nil
        @array_arg = nil
        @is_closure = false
      end

      def name
        @name ||= safe(arginfo.name)
      end

      def direction
        @direction ||= arginfo.direction
      end

      def type_info
        @type_info ||= arginfo.argument_type
      end

      def specialized_type_tag
        # SMELL: Law of Demeter, due to this being arginfo.argument_type.flattened_tag
        type_info.flattened_tag
      end

      # TODO: Use class rather than class name
      def argument_class_name
        type_info.argument_class_name
      end

      def array_length_idx
        type_info.array_length
      end

      def ownership_transfer
        arginfo.ownership_transfer
      end

      def safe(name)
        if KEYWORDS.include? name
          "#{name}_"
        else
          name
        end
      end

      def call_argument_name
        @call_argument_name ||= new_variable
      end

      def new_variable
        @var_gen.new_var
      end
    end
  end
end
