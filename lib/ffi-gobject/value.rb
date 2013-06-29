module GObject
  load_class :Value

  # Overrides for GValue, GObject's generic value container structure.
  class Value
    # TODO: Give more generic name
    def set_ruby_value val
      if current_gtype == 0
        init_for_ruby_value val
      end

      set_value val
    end

    TYPE_TO_SET_METHOD_MAP = {
      TYPE_BOOLEAN => :set_boolean,
      TYPE_INT => :set_int,
      TYPE_INT64 => :set_int64,
      TYPE_STRING => :set_string,
      TYPE_FLOAT => :set_float,
      TYPE_DOUBLE => :set_double,
      TYPE_PARAM => :set_param,
      TYPE_OBJECT => :set_instance_enhanced,
      TYPE_BOXED => :set_boxed,
      TYPE_POINTER => :set_pointer,
      TYPE_ENUM => :set_enum
    }

    def value= val
      set_value val
    end

    def set_value val
      send set_method, val
      self
    end

    CLASS_TO_GTYPE_MAP = {
      true => TYPE_BOOLEAN,
      false => TYPE_BOOLEAN,
      Integer => TYPE_INT,
      String => TYPE_STRING
    }

    def init_for_ruby_value val
      CLASS_TO_GTYPE_MAP.each do |klass, type|
        if klass === val
          init type
          return self
        end
      end
      raise "Can't handle #{val.class}"
    end

    def current_gtype
      @struct[:g_type]
    end

    def current_fundamental_type
      GObject.type_fundamental current_gtype
    end

    def current_gtype_name
      GObject.type_name current_gtype
    end

    TYPE_TO_GET_METHOD_MAP = {
      TYPE_BOOLEAN => :get_boolean,
      TYPE_INT => :get_int,
      TYPE_INT64 => :get_int64,
      TYPE_STRING => :get_string,
      TYPE_FLOAT => :get_float,
      TYPE_DOUBLE => :get_double,
      TYPE_OBJECT => :get_object,
      TYPE_BOXED => :get_boxed_enhanced,
      TYPE_POINTER => :get_pointer
    }

    def get_value
      send get_method
    end

    # @deprecated Compatibility function. Remove in 0.7.0.
    def ruby_value
      get_value
    end

    class << self
      # TODO: Give more generic name
      def wrap_ruby_value val
        self.new.set_ruby_value val
      end

      def from val
        case val
        when self
          val
        when nil
          nil
        else
          wrap_ruby_value val
        end
      end

      def for_g_type g_type
        return nil if g_type == TYPE_NONE
        self.new.init g_type
      end
    end

    # TODO: Combine with wrap_ruby_value
    def self.wrap_instance instance
      self.new.tap {|it|
        it.init GObject.type_from_instance instance
        it.set_instance instance
      }
    end

    private

    def set_instance_enhanced val
      check_type_compatibility val if val
      set_instance val
    end

    def check_type_compatibility val
      if !GObject::Value.type_compatible(GObject.type_from_instance(val), current_gtype)
        raise ArgumentError, "#{val.class} is incompatible with #{current_gtype_name}"
      end
    end

    def get_boxed_enhanced
      boxed = get_boxed
      gtype = current_gtype

      case gtype
      when TYPE_STRV
        GLib::Strv.wrap boxed
      when TYPE_HASH_TABLE
        GLib::HashTable.wrap [:gpointer, :gpointer], boxed
      else
        GirFFI::ArgHelper.wrap_object_pointer_by_gtype boxed, gtype
      end
    end

    def get_method
      TYPE_TO_GET_METHOD_MAP[current_fundamental_type] or
        raise "Can't find method to get #{current_gtype_name}"
    end

    def set_method
      TYPE_TO_SET_METHOD_MAP[current_fundamental_type] or
        raise "Can't find method to set #{current_gtype_name}"
    end
  end
end
