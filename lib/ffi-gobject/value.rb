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
      when TYPE_BOXED
        set_boxed val
      when TYPE_OBJECT
        set_instance val
      when TYPE_ENUM
        set_enum val
      else
        nil
      end
      self
    end

    def init_for_ruby_value val
      case val
      when true, false
        init ::GObject.type_from_name("gboolean")
      when Integer
        init ::GObject.type_from_name("gint")
      end
      self
    end

    def current_gtype
      self[:g_type]
    end

    def current_fundamental_type
      GObject.type_fundamental current_gtype
    end

    def current_gtype_name
      ::GObject.type_name current_gtype
    end

    def ruby_value
      case current_fundamental_type
      when TYPE_BOOLEAN
        return get_boolean
      when TYPE_INT
        return get_int
      when TYPE_STRING
        return get_string
      when TYPE_FLOAT
        return get_float
      when TYPE_DOUBLE
        return get_double
      when TYPE_OBJECT
        return get_object
      when TYPE_BOXED
        boxed = get_boxed
        case current_gtype_name.to_sym
        when :GDate
          return ::GLib::Date.wrap(boxed)
        when :GStrv
          # FIXME: Extract this method to even lower level module.
          return GirFFI::ArgHelper.strv_to_utf8_array boxed
        end
      end
      raise "Don't know how to handle #{current_gtype_name}"
    end

    class << self
      def wrap_ruby_value val
        self.new.set_ruby_value val
      end
    end
  end
end
