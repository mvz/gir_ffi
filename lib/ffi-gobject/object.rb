module GObject
  load_class :Object

  # Overrides for GObject, GObject's generic base class.
  class Object

    setup_method "new"

    # TODO: Generate accessor methods from GIR at class definition time
    def method_missing(method, *args)
      if respond_to?("get_#{method}")
        return send("get_#{method}", *args)
      end
      if method.to_s =~ /(.*)=$/ && respond_to?("set_#{$1}")
        return send("set_#{$1}", *args)
      end
      super
    end

    def signal_connect(event, &block)
      GObject.signal_connect(self, event, &block)
    end

    setup_instance_method "get_property"
    setup_instance_method "set_property"

    def get_property_with_override property_name
      type_info = get_property_type property_name
      pspec = type_class.find_property property_name

      gvalue = GObject::Value.for_g_type pspec.value_type
      get_property_without_override property_name, gvalue

      case type_info.tag
      when :ghash, :glist
        adjust_value_to_type gvalue.get_value_plain, type_info
      else
        gvalue.get_value
      end
    end

    def set_property_with_override property_name, value
      type_info = get_property_type property_name
      pspec = type_class.find_property property_name

      gvalue = GObject::Value.for_g_type pspec.value_type
      gvalue.set_value adjust_value_to_type(value, type_info)
      set_property_without_override property_name, gvalue
    end

    def type_class
      GObject::ObjectClass.wrap(self.to_ptr.get_pointer 0)
    end

    alias get_property_without_override get_property
    alias get_property get_property_with_override

    alias set_property_without_override set_property
    alias set_property set_property_with_override

    private

    def get_property_type property_name
      prop = self.class.find_property property_name
      prop.property_type
    end

    # TODO: Move to ITypeInfo
    def adjust_value_to_type val, type_info
      case type_info.flattened_tag
      when :ghash
        GLib::HashTable.from type_info.element_type, val
      when :glist
        GLib::List.from type_info.element_type, val
      when :strv
        GLib::Strv.from val
      else
        val
      end
    end
  end
end
