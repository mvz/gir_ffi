module GObject
  load_class :Object

  # Overrides for GObject, GObject's generic base class.
  class Object
    _setup_instance_method "get_property"
    _setup_instance_method "set_property"

    def get_property_with_override property_name
      prop = self.class._find_property property_name
      type = prop.property_type
      v = Helper.gvalue_for_type_info type
      get_property_without_override property_name, v

      val = v.ruby_value
      case type.tag
      when :ghash
        GLib::HashTable.wrap type.param_type(0).tag, type.param_type(1).tag,
          val.to_ptr
      when :glist
        GLib::List.wrap type.param_type(0).tag, val
      else
        val
      end
    end

    def set_property_with_override property_name, value
      prop = self.class._find_property property_name
      type = prop.property_type
      v = Helper.gvalue_for_type_info type
      v.set_value value
      set_property_without_override property_name, v
    end

    alias get_property_without_override get_property
    alias get_property get_property_with_override

    alias set_property_without_override set_property
    alias set_property set_property_with_override
  end
end

