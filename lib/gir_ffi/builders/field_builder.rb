require 'gir_ffi/builders/argument_builder'
require 'gir_ffi/builders/return_value_builder'
require 'gir_ffi/variable_name_generator'
require 'gir_ffi/field_argument_info'

module GirFFI
  module Builders
    # Creates field getter and setter code for a given IFieldInfo.
    class FieldBuilder
      attr_reader :info

      def initialize field_info
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
        container_class.class_eval setter_def if is_writable_field?
      end

      def is_writable_field?
        info.writable?
      end

      def getter_def
        builder = return_value_builder

        field_ptr = builder.new_variable
        typed_ptr = builder.new_variable

        <<-CODE.reset_indentation
        def #{info.name}
          #{field_ptr} = @struct.to_ptr + #{info.offset}
          #{typed_ptr} = GirFFI::InOutPointer.new(#{field_type_tag_or_class.inspect}, #{field_ptr})
          #{builder.capture_variable_name} = #{typed_ptr}.to_value
          #{builder.post_conversion.join("\n")}
          #{builder.return_value_name}
        end
        CODE
      end

      def setter_def
        builder = setter_builder

        field_ptr = builder.new_variable
        typed_ptr = builder.new_variable

        <<-CODE.reset_indentation
        def #{info.name}= #{builder.method_argument_name}
          #{field_ptr} = @struct.to_ptr + #{info.offset}
          #{typed_ptr} = GirFFI::InOutPointer.new(#{field_type_tag_or_class.inspect}, #{field_ptr})
          #{builder.pre_conversion.join("\n          ")}
          #{typed_ptr}.set_value #{builder.call_argument_name}
        end
        CODE
      end

      private

      def struct_class
        container_class::Struct
      end

      def field_type_tag_or_class
        @field_type_tag_or_class ||= info.field_type.tag_or_class
      end

      def container_class
        @container_class ||= container_module.const_get(container_info.safe_name)
      end

      def container_module
        @container_module ||= Object.const_get(container_info.safe_namespace)
      end

      def container_info
        @container_info ||= info.container
      end

      def field_symbol
        @info.name.to_sym
      end

      def field_type
        @field_type ||= @info.field_type
      end

      def field_argument_info
        @field_argument_info ||= FieldArgumentInfo.new "value", field_type
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
