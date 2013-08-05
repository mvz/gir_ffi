module GLib
  # Implementation of gboolean
  class Boolean
    extend FFI::DataConverter
    native_type :int #FFI::Type::INT

    def self.from_native value, context
      value != 0 ? true : false
    end

    def self.to_native value, context
      value ? 1 : 0
    end
  end
end
