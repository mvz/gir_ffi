module GirFFI
  module Builder
    class DynamicType
      def initialize gtype
      end

      def build_class
        Class.new
      end
    end
  end
end
