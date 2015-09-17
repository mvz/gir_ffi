require 'gir_ffi/builders/argument_builder'
require 'gir_ffi/builders/return_value_builder'
require 'gir_ffi/variable_name_generator'
require 'gir_ffi/field_argument_info'

module GirFFI
  module Builders
    # Creates field getter and setter code for a given IFieldInfo.
    class FieldBuilder
      # Builder for field getters
      class GetterBuilder
        def initialize(field_builder, return_value_builder)
          @field_builder = field_builder
          @return_value_builder = return_value_builder
        end

        def singleton_method?
          false
        end

        def method_name
          @field_builder.field_name
        end

        def method_arguments
          []
        end

        def preparation
          [
            "#{field_ptr} = @struct.to_ptr + #{field_offset}",
            "#{typed_ptr} = GirFFI::InOutPointer.new(#{field_type_tag}, #{field_ptr})"
          ]
        end

        def invocation
          "#{typed_ptr}.to_value"
        end

        def result
          [@return_value_builder.return_value_name]
        end

        private

        def field_ptr
          @field_ptr ||= @return_value_builder.new_variable
        end

        def typed_ptr
          @typed_ptr ||= @return_value_builder.new_variable
        end

        def field_offset
          @field_builder.field_offset
        end

        def field_type_tag
          @field_builder.field_type_tag
        end
      end

      attr_reader :info

      def initialize(field_info)
        @info = field_info
      end

      def build
        setup_getter
        setup_setter
      end

      def setup_getter
        container_class.class_eval getter_def unless container_defines_getter_method?
      end

      def container_defines_getter_method?
        container_info.find_instance_method info.name
      end

      def setup_setter
        container_class.class_eval setter_def if info.writable?
      end

      def getter_def
        argument_builders = ArgumentBuilderCollection.new(return_value_builder, [])
        getter_builder = GetterBuilder.new(self, return_value_builder)
        MethodTemplate.new(getter_builder, argument_builders).method_definition
      end

      # TODO: Use MethodTemplate
      def setter_def
        builder = setter_builder

        field_ptr = builder.new_variable
        typed_ptr = builder.new_variable

        <<-CODE.reset_indentation
        def #{info.name}= #{builder.method_argument_name}
          #{field_ptr} = @struct.to_ptr + #{info.offset}
          #{typed_ptr} = GirFFI::InOutPointer.new(#{field_type_tag}, #{field_ptr})
          #{builder.pre_conversion.join("\n          ")}
          #{typed_ptr}.set_value #{builder.call_argument_name}
        end
        CODE
      end

      def field_name
        @field_name ||= info.name
      end

      def field_offset
        @field_offset ||= info.offset
      end

      def field_type_tag
        @field_type_tag ||= info.field_type.tag_or_class.inspect
      end

      private

      def container_class
        @container_class ||= container_module.const_get(container_info.safe_name)
      end

      def container_module
        @container_module ||= Object.const_get(container_info.safe_namespace)
      end

      def container_info
        @container_info ||= info.container
      end

      def field_type
        @field_type ||= @info.field_type
      end

      def field_argument_info
        @field_argument_info ||= FieldArgumentInfo.new 'value', field_type
      end

      def return_value_builder
        @rv_builder ||= ReturnValueBuilder.new(VariableNameGenerator.new,
                                               field_argument_info)
      end

      def setter_builder
        @setter_builder ||= ArgumentBuilder.new(VariableNameGenerator.new,
                                                field_argument_info)
      end
    end
  end
end
