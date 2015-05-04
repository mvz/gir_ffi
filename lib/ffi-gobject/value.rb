GObject.load_class :Value

module GObject
  # Overrides for GValue, GObject's generic value container structure.
  class Value

    # TODO: Give more generic name
    def set_ruby_value val
      init_for_ruby_value val if current_gtype == 0
      set_value val
    end

    METHOD_MAP = {
      TYPE_BOOLEAN => [:get_boolean,       :set_boolean],
      TYPE_BOXED   => [:get_boxed,         :set_boxed],
      TYPE_CHAR    => [:get_char,          :set_char],
      TYPE_DOUBLE  => [:get_double,        :set_double],
      TYPE_ENUM    => [:get_enum_enhanced, :set_enum_enhanced],
      TYPE_FLAGS   => [:get_flags,         :set_flags],
      TYPE_FLOAT   => [:get_float,         :set_float],
      TYPE_GTYPE   => [:get_gtype,         :set_gtype],
      TYPE_INT     => [:get_int,           :set_int],
      TYPE_INT64   => [:get_int64,         :set_int64],
      TYPE_LONG    => [:get_long,          :set_long],
      TYPE_OBJECT  => [:get_object,        :set_instance_enhanced],
      TYPE_PARAM   => [:get_param,         :set_param],
      TYPE_POINTER => [:get_pointer,       :set_pointer],
      TYPE_STRING  => [:get_string,        :set_string],
      TYPE_UCHAR   => [:get_uchar,         :set_uchar],
      TYPE_UINT    => [:get_uint,          :set_uint],
      TYPE_UINT64  => [:get_uint64,        :set_uint64],
      TYPE_ULONG   => [:get_ulong,         :set_ulong],
      TYPE_VARIANT => [:get_variant,       :set_variant]
    }

    def set_value val
      send set_method, val
    end

    alias_method :value=, :set_value

    CLASS_TO_GTYPE_MAP = {
      TrueClass => TYPE_BOOLEAN,
      FalseClass => TYPE_BOOLEAN,
      Integer => TYPE_INT,
      String => TYPE_STRING
    }

    def self.make_finalizer ptr, name
      proc {
        GObject::Lib.g_value_unset ptr
      }
    end

    def init_for_ruby_value val
      CLASS_TO_GTYPE_MAP.each do |klass, type|
        if val.is_a? klass
          init type
          ObjectSpace.define_finalizer self, self.class.make_finalizer(self.to_ptr, self.class.name) 
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

    def get_value
      value = get_value_plain
      if current_fundamental_type == TYPE_BOXED
        wrap_boxed value
      else
        value
      end
    end

    def get_value_plain
      send get_method
    end

    # TODO: Give more generic name
    def self.wrap_ruby_value val
      new.tap { |gv| gv.set_ruby_value val }
    end

    def self.from val
      case val
      when self
        val
      when nil
        nil
      else
        wrap_ruby_value val
      end
    end

    # @deprecated Use GObject::Value.for_gtype instead. Will be removed in 0.8.0.
    def self.for_g_type g_type
      for_gtype g_type
    end

    def self.for_gtype gtype
      return nil if gtype == TYPE_NONE
      new.tap do |it| 
        it.init gtype 
        ObjectSpace.define_finalizer it, make_finalizer(it.to_ptr, it.class.name) 
      end
    end

    # TODO: Combine with wrap_ruby_value
    def self.wrap_instance instance
      new.tap do |it|
        it.init GObject.type_from_instance instance
        ObjectSpace.define_finalizer it, make_finalizer(it.to_ptr, it.class.name) 
        it.set_instance instance
      end
    end

    private

    def set_instance_enhanced val
      check_type_compatibility val if val
      set_instance val
    end

    def set_enum_enhanced val
      val = current_gtype_class[val] if val.is_a? Symbol
      set_enum val
    end

    def get_enum_enhanced
      current_gtype_class.wrap(get_enum)
    end

    def current_gtype_class
      GirFFI::Builder.build_by_gtype(current_gtype)
    end

    def check_type_compatibility val
      unless GObject::Value.type_compatible(GObject.type_from_instance(val), current_gtype)
        raise ArgumentError, "#{val.class} is incompatible with #{current_gtype_name}"
      end
    end

    def wrap_boxed boxed
      case current_gtype
      when TYPE_STRV
        GLib::Strv.wrap boxed
      when TYPE_HASH_TABLE
        GLib::HashTable.wrap [:gpointer, :gpointer], boxed
      when TYPE_ARRAY
        GLib::Array.wrap nil, boxed
      else
        current_gtype_class.wrap(boxed) unless boxed.null?
      end
    end

    def get_method
      method_map_entry.first
    end

    def set_method
      method_map_entry.last
    end

    def method_map_entry
      METHOD_MAP[current_gtype] || METHOD_MAP[current_fundamental_type] ||
        raise("No method map entry for #{current_gtype_name}")
    end
  end
end
