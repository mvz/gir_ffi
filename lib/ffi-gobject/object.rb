# frozen_string_literal: true
require 'gir_ffi/property_not_found_error'

GObject.load_class :Object

module GObject
  # Overrides for GObject, GObject's generic base class.
  class Object
    setup_method 'new'

    def initialize_with_automatic_gtype(properties = {})
      gparameters = properties.map do |name, value|
        name = name.to_s
        property_param_spec(name)
        GObject::Parameter.new.tap do |gparam|
          gparam.name = name
          gparam.value = value
        end
      end
      initialize_without_automatic_gtype(self.class.gtype, gparameters)
    end

    alias_method :initialize_without_automatic_gtype, :initialize
    alias_method :initialize, :initialize_with_automatic_gtype
    alias_method :base_initialize, :initialize

    private :base_initialize

    def store_pointer(ptr)
      super
      klass = self.class
      ObjectSpace.define_finalizer self, klass.make_finalizer(ptr, klass.name)
    end

    def self.make_finalizer(ptr, name)
      proc do
        rc = GObject::Object::Struct.new(ptr)[:ref_count]
        if rc == 0
          warn "not unreffing #{name}:#{ptr} (#{rc})"
        else
          GObject::Lib.g_object_unref ptr
        end
      end
    end

    # TODO: Generate accessor methods from GIR at class definition time
    def method_missing(method, *args)
      getter_name = "get_#{method}"
      return send(getter_name, *args) if respond_to?(getter_name)
      if method.to_s =~ /(.*)=$/
        setter_name = "set_#{Regexp.last_match[1]}"
        return send(setter_name, *args) if respond_to?(setter_name)
      end
      super
    end

    def signal_connect(event, data = nil, &block)
      GObject.signal_connect(self, event, data, &block)
    end

    def signal_connect_after(event, data = nil, &block)
      GObject.signal_connect_after(self, event, data, &block)
    end

    setup_instance_method 'get_property'
    setup_instance_method 'set_property'

    def get_property_extended(property_name)
      value = get_property(property_name)
      type_info = get_property_type property_name
      case type_info.tag
      when :ghash, :glist
        adjust_value_to_type value, type_info
      else
        value
      end
    end

    def get_property_with_override(property_name)
      gvalue = gvalue_for_property property_name
      get_property_without_override property_name, gvalue
      gvalue.get_value
    end

    def set_property_extended(property_name, value)
      type_info = get_property_type property_name
      adjusted_value = adjust_value_to_type(value, type_info)

      set_property property_name, adjusted_value
    end

    def set_property_with_override(property_name, value)
      gvalue = gvalue_for_property(property_name)
      gvalue.set_value value
      set_property_without_override property_name, gvalue
    end

    alias_method :get_property_without_override, :get_property
    alias_method :get_property, :get_property_with_override

    alias_method :set_property_without_override, :set_property
    alias_method :set_property, :set_property_with_override

    setup_instance_method 'is_floating'
    alias_method :floating?, :is_floating

    private

    def get_property_type(property_name)
      prop = self.class.find_property(property_name)
      prop.property_type
    end

    def gvalue_for_property(property_name)
      gtype = property_gtype property_name
      GObject::Value.for_gtype gtype
    end

    def property_gtype(property_name)
      pspec = property_param_spec(property_name)
      pspec.value_type
    end

    def property_param_spec(property_name)
      object_class.find_property property_name or
        raise GirFFI::PropertyNotFoundError.new(property_name, self.class)
    end

    # TODO: Move to ITypeInfo
    def adjust_value_to_type(val, type_info)
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
