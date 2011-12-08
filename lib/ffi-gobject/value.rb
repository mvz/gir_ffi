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

    def set_value val
      case current_fundamental_type
      when TYPE_BOOLEAN
        set_boolean val
      when TYPE_INT
        set_int val
      when TYPE_STRING
        set_string val
      when TYPE_FLOAT
        set_float val
      when TYPE_DOUBLE
        set_double val
      when TYPE_BOXED
        set_boxed val
      when TYPE_OBJECT
        set_instance val
      when TYPE_POINTER
        set_pointer val
      when TYPE_ENUM
        set_enum val
      else
        raise "Don't know how to handle #{current_gtype_name}"
      end
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

    def ruby_value
      case current_fundamental_type
      when TYPE_BOOLEAN
        get_boolean
      when TYPE_INT
        get_int
      when TYPE_STRING
        get_string
      when TYPE_FLOAT
        get_float
      when TYPE_DOUBLE
        get_double
      when TYPE_OBJECT
        get_object
      when TYPE_BOXED
        get_boxed_enhanced
      when TYPE_POINTER
        get_pointer
      else
        raise "Don't know how to handle #{current_gtype_name}"
      end
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
        GLib::HashTable.wrap :gpointer, :gpointer, boxed
      else
        GirFFI::ArgHelper.wrap_object_pointer_by_gtype boxed, current_gtype
      end
    end
  end
end
