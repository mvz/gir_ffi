require 'ffi-gobject/ruby_style'

module GObject
  load_class :Object

  # Overrides for GObject, GObject's generic base class.
  class Object

    include RubyStyle

    _setup_method "new"
    _setup_instance_method "get_property"
    _setup_instance_method "set_property"

    def get_property_with_override property_name
      type = get_property_type property_name
      gvalue = Helper.gvalue_for_type_info type

      get_property_without_override property_name, gvalue

      adjust_value_to_type gvalue.ruby_value, type
    end

    def set_property_with_override property_name, value
      type = get_property_type property_name
      gvalue = Helper.gvalue_for_type_info type

      gvalue.set_value adjust_value_to_type(value, type)

      set_property_without_override property_name, gvalue
    end

    alias get_property_without_override get_property
    alias get_property get_property_with_override

    alias set_property_without_override set_property
    alias set_property set_property_with_override

    private

    def get_property_type property_name
      prop = self.class._find_property property_name
      prop.property_type
    end

    def adjust_value_to_type val, type
      case type.tag
      when :ghash
        GLib::HashTable.from [type.param_type(0).tag, type.param_type(1).tag],
          val
      when :glist
        GLib::List.from type.param_type(0).tag, val
      else
        val
      end
    end
  end
end
