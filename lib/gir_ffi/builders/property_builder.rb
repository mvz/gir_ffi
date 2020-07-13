# frozen_string_literal: true

require "gir_ffi/builders/method_template"
require "gir_ffi/builders/argument_builder_collection"
require "gir_ffi/builders/property_argument_builder"
require "gir_ffi/builders/property_return_value_builder"
require "gir_ffi/variable_name_generator"
require "gir_ffi/field_argument_info"

module GirFFI
  module Builders
    # Method builder used for the creation of property getter methods.
    class PropertyGetterBuilder
      attr_reader :info, :return_value_builder

      def initialize(info, return_value_builder)
        @return_value_builder = return_value_builder
        @info = info
      end

      def method_definition
        template.method_definition
      end

      def template
        @template ||= MethodTemplate.new(self, argument_builder_collection)
      end

      def singleton_method?
        false
      end

      def method_name
        info.getter_name
      end

      def method_arguments
        []
      end

      def preparation
        []
      end

      def invocation
        "get_property('#{info.name}')"
      end

      def result
        [return_value_builder.return_value_name]
      end

      private

      def argument_builder_collection
        @argument_builder_collection ||=
          ArgumentBuilderCollection.new(return_value_builder, [])
      end
    end

    # Creates property getter and setter code for a given IPropertyInfo.
    class PropertyBuilder
      def initialize(property_info)
        @info = property_info
      end

      def build
        setup_getter
        setup_setter if setting_allowed
      end

      def setup_getter
        return if container_defines_getter_method?

        container_class.class_eval getter_def, __FILE__, __LINE__
      end

      def container_defines_getter_method?
        container_info.find_instance_method getter_name
      end

      def setup_setter
        container_class.class_eval setter_def, __FILE__, __LINE__
      end

      def getter_def
        PropertyGetterBuilder.new(@info, getter_builder).method_definition
      end

      def setter_def
        converting_setter_def
      end

      private

      def getter_builder
        @getter_builder ||=
          PropertyReturnValueBuilder.new(VariableNameGenerator.new,
                                         argument_info)
      end

      def converting_setter_def
        <<~CODE
          def #{setter_name} value
            #{setter_builder.pre_conversion.join("\n")}
            set_property("#{property_name}", #{setter_builder.call_argument_name})
          end
        CODE
      end

      def setter_builder
        @setter_builder ||=
          PropertyArgumentBuilder.new(VariableNameGenerator.new,
                                      argument_info)
      end

      def property_name
        @info.name
      end

      def getter_name
        @info.getter_name
      end

      def setter_name
        @info.setter_name
      end

      def type_info
        @type_info ||= @info.property_type
      end

      def argument_info
        @argument_info ||= FieldArgumentInfo.new("value", type_info)
      end

      def container_class
        @container_class ||= container_module.const_get(container_info.safe_name)
      end

      def container_module
        @container_module ||= Object.const_get(container_info.safe_namespace)
      end

      # TODO: Inject container_info on initialization
      def container_info
        @container_info ||= @info.container
      end

      def setting_allowed
        @info.writeable? && !@info.construct_only?
      end
    end
  end
end
