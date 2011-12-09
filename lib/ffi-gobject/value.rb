module GObject
  load_class :Value

  # Overrides for GValue, GObject's generic value container structure.
  class Value
    def set_ruby_value val
      if current_gtype == 0
        init_for_ruby_value val
      end

      set_value val
    end

    TYPE_TO_SET_METHOD = {
      TYPE_BOOLEAN => :set_boolean,
      TYPE_INT => :set_int,
      TYPE_STRING => :set_string,
      TYPE_FLOAT => :set_float,
      TYPE_DOUBLE => :set_double,
      TYPE_OBJECT => :set_instance,
      TYPE_BOXED => :set_boxed,
      TYPE_POINTER => :set_pointer,
      TYPE_ENUM => :set_enum
    }

    def set_value val
      method = TYPE_TO_SET_METHOD[current_fundamental_type]
      call_or_raise method, val
      self
    end

    def init_for_ruby_value val
      case val
      when true, false
        init TYPE_BOOLEAN
      when Integer
        init TYPE_INT
      end
      self
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

    TYPE_TO_GET_METHOD = {
      TYPE_BOOLEAN => :get_boolean,
      TYPE_INT => :get_int,
      TYPE_STRING => :get_string,
      TYPE_FLOAT => :get_float,
      TYPE_DOUBLE => :get_double,
      TYPE_OBJECT => :get_object,
      TYPE_BOXED => :get_boxed_enhanced,
      TYPE_POINTER => :get_pointer
    }

    def ruby_value
      method = TYPE_TO_GET_METHOD[current_fundamental_type]
      call_or_raise method
    end

    class << self
      def wrap_ruby_value val
        self.new.set_ruby_value val
      end
    end

    private

    def get_boxed_enhanced
      boxed = get_boxed
      case current_gtype
      when TYPE_STRV
        GirFFI::ArgHelper.strv_to_utf8_array boxed
      when TYPE_HASH_TABLE
        GLib::HashTable.wrap [:gpointer, :gpointer], boxed
      else
        GirFFI::ArgHelper.wrap_object_pointer_by_gtype boxed, current_gtype
      end
    end

    def call_or_raise method, *args
      if method
        send method, *args
      else
        raise "Don't know how to handle #{current_gtype_name}"
      end
    end
  end
end
