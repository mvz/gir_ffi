# frozen_string_literal: true
require 'gir_ffi/builders/argument_builder'
require 'gir_ffi/builders/base_argument_builder'
require 'gir_ffi/builders/null_argument_builder'
require 'gir_ffi/builders/pointer_value_convertor'
require 'gir_ffi/variable_name_generator'
require 'gir_ffi/field_argument_info'

module GirFFI
  module Builders
    # Creates field getter and setter code for a given IFieldInfo.
    class FieldBuilder
      # Convertor for fields for field getters. Used when building getter
      # methods.
      class GetterArgumentBuilder < BaseArgumentBuilder
        attr_reader :array_length_idx

        def initialize(var_gen, field_argument_info, field_info,
                       array_length_idx: -1)
          super(var_gen, field_argument_info)
          @field_info = field_info
          @length_arg = NullArgumentBuilder.new
          @array_length_idx = array_length_idx
        end

        def pre_conversion
          [
            "#{field_ptr} = @struct.to_ptr + #{field_offset}",
            "#{bare_value} = #{pointer_to_value_conversion}"
          ]
        end

        def capture_variable_name
          nil
        end

        def post_converted_name
          @post_converted_name ||= if has_post_conversion?
                                     new_variable
                                   else
                                     bare_value
                                   end
        end

        def return_value_name
          post_converted_name
        end

        def post_conversion
          if has_post_conversion?
            ["#{post_converted_name} = #{post_convertor.conversion}"]
          else
            []
          end
        end

        private

        def pointer_to_value_conversion
          PointerValueConvertor.new(field_type_tag).pointer_to_value(field_ptr)
        end

        def field_offset
          @field_info.offset
        end

        def field_ptr
          @field_ptr ||= @var_gen.new_var
        end

        def typed_ptr
          @typed_ptr ||= @var_gen.new_var
        end

        def bare_value
          @bare_value ||= @var_gen.new_var
        end

        def field_type_tag
          @field_type_tag ||= @field_info.field_type.tag_or_class
        end

        def field_type
          @field_type ||= @field_info.field_type
        end

        def has_post_conversion?
          type_info.needs_c_to_ruby_conversion_for_functions?
        end

        def post_convertor
          @post_convertor ||= CToRubyConvertor.new(type_info,
                                                   bare_value,
                                                   length_arg.post_converted_name)
        end
      end

      # Class to represent argument info for the argument of a getter method.
      # Implements the necessary parts of IArgumentInfo's interface.
      class GetterArgumentInfo
        attr_reader :name, :argument_type

        def initialize(name, type)
          @name = name
          @argument_type = type
        end

        def closure
          -1
        end

        def destroy
          -1
        end

        def direction
          :out
        end

        def ownership_transfer
          :nothing
        end

        def caller_allocates?
          false
        end

        def skip?
          false
        end
      end

      # Builder for field getters
      # TODO: Derive from BaseMethodBuilder
      class GetterBuilder
        def initialize(info)
          @info = info
        end

        def method_definition
          template.method_definition
        end

        def singleton_method?
          false
        end

        def method_name
          @info.name
        end

        def method_arguments
          []
        end

        def preparation
          []
        end

        def invocation
          nil
        end

        def result
          [getter_argument_builder.return_value_name]
        end

        private

        def var_gen
          @var_gen ||= VariableNameGenerator.new
        end

        def template
          @template ||= MethodTemplate.new(self, argument_builders)
        end

        def argument_builders
          @argument_builders ||=
            ArgumentBuilderCollection.new(
              NullReturnValueBuilder.new,
              base_argument_builders)
        end

        def base_argument_builders
          if array_length_field
            [getter_argument_builder, length_argument_builder]
          else
            [getter_argument_builder]
          end
        end

        def getter_argument_builder
          @getter_argument_builder ||=
            GetterArgumentBuilder.new(var_gen, field_argument_info, @info,
                                      array_length_idx: array_length_field ? 1 : -1)
        end

        def length_argument_builder
          @length_argument_builder ||=
            GetterArgumentBuilder.new(var_gen, length_argument_info, array_length_field)
        end

        def array_length_field
          @info.related_array_length_field
        end

        def length_argument_info
          @length_argument_info ||=
            GetterArgumentInfo.new 'length', array_length_field.field_type
        end

        def field_offset
          @info.offset
        end

        def field_type_tag
          @field_type_tag ||= @info.field_type.tag_or_class.inspect
        end

        def field_type
          @field_type ||= @info.field_type
        end

        def field_argument_info
          @field_argument_info ||= GetterArgumentInfo.new 'value', field_type
        end
      end

      attr_reader :info

      def initialize(field_info, container_class)
        @info = field_info
        @container_class = container_class
      end

      def build
        setup_getter
        setup_setter
      end

      def setup_getter
        return if container_defines_getter_method?
        return if hidden_struct_type?
        container_class.class_eval getter_def
      end

      def container_defines_getter_method?
        container_info.find_instance_method info.name
      end

      def setup_setter
        return unless info.writable?
        return if hidden_struct_type?
        container_class.class_eval setter_def
      end

      def getter_def
        getter_builder = GetterBuilder.new(info)
        getter_builder.method_definition
      end

      # TODO: Use MethodTemplate
      def setter_def
        builder = setter_builder

        field_ptr = builder.new_variable

        <<-CODE.reset_indentation
        def #{info.name}= #{builder.method_argument_name}
          #{field_ptr} = @struct.to_ptr + #{info.offset}
          #{builder.pre_conversion.join("\n          ")}
          #{value_storage(field_ptr, builder)}
        end
        CODE
      end

      private

      def value_storage(typed_ptr, builder)
        PointerValueConvertor.new(field_type_tag).
          value_to_pointer(typed_ptr, builder.call_argument_name)
      end

      def field_type_tag
        @field_type_tag ||= field_type.tag_or_class
      end

      attr_reader :container_class

      def container_info
        @container_info ||= info.container
      end

      def field_type
        @field_type ||= @info.field_type
      end

      def field_argument_info
        @field_argument_info ||= FieldArgumentInfo.new 'value', field_type
      end

      def setter_builder
        @setter_builder ||= ArgumentBuilder.new(VariableNameGenerator.new,
                                                field_argument_info)
      end

      def hidden_struct_type?
        field_type.hidden_struct_type?
      end
    end
  end
end
