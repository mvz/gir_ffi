module GObject
  load_class :Object

  # Overrides for GObject, GObject's generic base class.
  class Object
    _setup_instance_method "get_property"

    def get_property_with_override property_name
      v = Value.new
      get_property_without_override property_name, v
      v.ruby_value
    end

    alias get_property_without_override get_property
    alias get_property get_property_with_override
  end
end

