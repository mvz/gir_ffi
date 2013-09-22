module GirFFI
  module Builder
    # Creates property getter and setter code for a given IPropertyInfo.
    class Property
      def initialize property_info
        @info = property_info
      end

      def getter_def
        return <<-CODE
        def #{@info.getter_name}
          get_property "#{@info.name}"
        end
        CODE
      end

      def setter_def
        return <<-CODE
        def #{@info.getter_name}= value
          set_property "#{@info.name}", value
        end
        CODE
      end
    end
  end
end
