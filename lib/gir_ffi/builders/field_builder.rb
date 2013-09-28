require 'gir_ffi/builders/argument_builder'
require 'gir_ffi/builders/return_value_builder'
require 'gir_ffi/variable_name_generator'
require 'gir_ffi/setter_argument_info'

module GirFFI
  module Builders
    # Creates field getter and setter code for a given IFieldInfo.
    class FieldBuilder
      attr_reader :info

      def initialize field_info
        @info = field_info
      end

      def build
        unless container_info.find_instance_method info.name
          container_class.class_eval getter_def
        end
        container_class.class_eval setter_def if info.writable?
      end

      def getter_def
        builder = return_value_builder

        field_ptr = builder.new_variable
        typed_ptr = builder.new_variable

        return <<-CODE.reset_indentation
        def #{info.name}
          #{field_ptr} = @struct.to_ptr + #{info.offset}
          #{typed_ptr} = GirFFI::InOutPointer.new(#{field_type_tag_or_class.inspect}, #{field_ptr})
          #{builder.callarg} = #{typed_ptr}.to_value
          #{builder.post.join("\n")}
          #{builder.retval}
        end
        CODE
      end

      def setter_def
        builder = setter_builder

        field_ptr = builder.new_variable
        typed_ptr = builder.new_variable

        return <<-CODE.reset_indentation
        def #{info.name}= #{builder.inarg}
          #{field_ptr} = @struct.to_ptr + #{info.offset}
          #{typed_ptr} = GirFFI::InOutPointer.new(#{field_type_tag_or_class.inspect}, #{field_ptr})
          #{builder.pre.join("\n          ")}
          #{typed_ptr}.set_value #{builder.callarg}
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

      def return_value_builder
        vargen = VariableNameGenerator.new
        @rv_builder ||= ReturnValueBuilder.new vargen, @info.field_type
      end

      def setter_builder
        vargen = VariableNameGenerator.new
        argument_info = SetterArgumentInfo.new "value", @info.field_type
        ArgumentBuilder.new vargen, argument_info
      end
    end
  end
end
