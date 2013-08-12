require 'gir_ffi/argument_builder'
require 'gir_ffi/return_value_builder'
require 'gir_ffi/variable_name_generator'
require 'gir_ffi/setter_argument_info'

module GirFFI
  # Creates field getter and setter code for a given IFieldInfo.
  class FieldBuilder
    def initialize field_info
      @info = field_info
    end

    def build
      unless container_info.find_instance_method info.name
        container_class.class_eval getter_def
      end
      container_class.class_eval setter_def if info.writable?
    end

    private

    def getter_def
      builder = return_value_builder

      return <<-CODE
      def #{@info.name}
        struct = #{struct_class}.new @struct.to_ptr
        #{builder.callarg} = struct[#{field_symbol.inspect}]
        #{builder.post.join("\n")}
        #{builder.retval}
      end
      CODE
    end

    def setter_def
      builder = setter_builder
      name = @info.name

      return <<-CODE
      def #{name}= #{builder.inarg}
        #{builder.pre.join("\n")}
        struct = #{struct_class}.new @struct.to_ptr
        struct[#{name.to_sym.inspect}] = #{builder.callarg}
      end
      CODE
    end

    attr_reader :info

    def struct_class
      container_class::Struct
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
      @rv_builder ||= ReturnValueBuilder.new vargen, @info.field_type, false
    end

    def setter_builder
      vargen = VariableNameGenerator.new
      argument_info = SetterArgumentInfo.new "value", @info.field_type
      ArgumentBuilder.new vargen, argument_info
    end
  end
end
