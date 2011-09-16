module GObject
  load_class :Value

  class Value
    def set_ruby_value val
      if current_gtype == 0
        init_for_ruby_value val
      end

      case current_gtype_name
      when "gboolean"
        set_boolean val
      when "gint"
        set_int val
      when "gchararray"
        set_string val
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

    def current_gtype_name
      ::GObject.type_name current_gtype
    end

    def ruby_value
      case current_gtype_name.to_sym
      when :gboolean
        get_boolean
      when :gint
        get_int
      when :gchararray
        get_string
      when :GDate
        ::GLib::Date.wrap(get_boxed)
      when :GStrv
        # FIXME: Extract this method to even lower level module.
        GirFFI::ArgHelper.strv_to_utf8_array get_boxed
      else
        nil
      end
    end

    class << self
      def wrap_ruby_value val
        self.new.set_ruby_value val
      end
    end
  end
end
