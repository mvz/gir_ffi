module GirFFI
  module Builders
    # Creates property getter and setter code for a given IPropertyInfo.
    class PropertyBuilder
      def initialize property_info
        @info = property_info
      end

      def getter_def
        case type_info.tag
        when :glist, :ghash
          argument_info = FieldArgumentInfo.new(@info.getter_name, type_info)
          builder = ReturnValueBuilder.new(VariableNameGenerator.new, argument_info)

          return <<-CODE.reset_indentation
          def #{@info.getter_name}
            #{builder.callarg} = get_property_basic("#{@info.name}").get_value_plain
            #{builder.post.join("\n")}
            #{builder.retval}
          end
          CODE
        else
          return <<-CODE.reset_indentation
          def #{@info.getter_name}
            get_property_basic("#{@info.name}").get_value
          end
          CODE
        end
      end

      def setter_def
        return <<-CODE
        def #{@info.getter_name}= value
          set_property "#{@info.name}", value
        end
        CODE
      end

      private

      def type_info
        @type_info ||= @info.property_type
      end

    end
  end
end
