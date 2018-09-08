# frozen_string_literal: true

require 'gir_ffi/property_not_found_error'

GObject.load_class :Object

module GObject
  # Overrides for GObject, GObject's generic base class.
  class Object
    if !GLib.check_version(2, 54, 0)
      GObject::Lib.attach_function(:g_object_new_with_properties,
                                   [:size_t, :uint32, :pointer, :pointer],
                                   :pointer)

      def self.new(*args, &block)
        obj = allocate
        obj.__send__ :initialize, *args, &block
        obj
      end

      # Starting with GLib 2.54.0, use g_object_new_with_properties, which
      # takes an array of names and an array of values.
      def initialize(properties = {})
        names = []
        values = []
        properties.each do |name, value|
          name = name.to_s
          gvalue = gvalue_for_property(name)
          gvalue.set_value value

          names << name
          values << gvalue
        end

        n_properties = names.length
        names_arr = GirFFI::SizedArray.from(:utf8, -1, names)
        values_arr = GirFFI::SizedArray.from(GObject::Value, -1, values)

        ptr = GObject::Lib.g_object_new_with_properties(self.class.gtype,
                                                        n_properties,
                                                        names_arr,
                                                        values_arr)
        store_pointer ptr
      end
    else
      setup_method! 'new'

      # Before GLib 2.54.0, use g_object_newv, which takes an array of GParameter.
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

      alias initialize_without_automatic_gtype initialize
      alias initialize initialize_with_automatic_gtype
    end

    alias base_initialize initialize

    private :base_initialize

    remove_method :ref

    def ref
      Lib.g_object_ref self
      self
    end

    def store_pointer(ptr)
      super
      ObjectSpace.define_finalizer self, self.class.make_finalizer(ptr)
    end

    def self.make_finalizer(ptr)
      proc do
        rc = GObject::Object::Struct.new(ptr)[:ref_count]
        if rc.zero?
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

    def respond_to_missing?(*)
      false
    end

    def signal_connect(event, data = nil, &block)
      GObject.signal_connect(self, event, data, &block)
    end

    def signal_connect_after(event, data = nil, &block)
      GObject.signal_connect_after(self, event, data, &block)
    end

    setup_instance_method! 'get_property'
    setup_instance_method! 'set_property'

    def get_property_extended(property_name)
      value = get_property(property_name)
      type_info = get_property_type property_name
      property_value_post_conversion value, type_info
    end

    def get_property_with_override(property_name)
      gvalue = gvalue_for_property property_name
      get_property_without_override property_name, gvalue
      gvalue.get_value
    end

    def set_property_extended(property_name, value)
      type_info = get_property_type property_name
      adjusted_value = property_value_pre_conversion(value, type_info)
      set_property property_name, adjusted_value
    end

    def set_property_with_override(property_name, value)
      gvalue = gvalue_for_property(property_name)
      gvalue.set_value value
      set_property_without_override property_name, gvalue
    end

    alias get_property_without_override get_property
    alias get_property get_property_with_override

    alias set_property_without_override set_property
    alias set_property set_property_with_override

    setup_instance_method! 'is_floating'
    alias floating? is_floating

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

    # TODO: Move to ITypeInfo and unify with ArgHelper.cast_from_pointer
    def property_value_post_conversion(val, type_info)
      case type_info.flattened_tag
      when :ghash
        GLib::HashTable.from type_info.element_type, val
      when :glist
        GLib::List.from type_info.element_type, val
      when :callback
        GirFFI::Builder.build_class(type_info.interface).wrap val
      else
        val
      end
    end

    # TODO: Move to ITypeInfo and unify with ArgHelper.cast_from_pointer
    def property_value_pre_conversion(val, type_info)
      case type_info.flattened_tag
      when :ghash
        GLib::HashTable.from type_info.element_type, val
      when :glist
        GLib::List.from type_info.element_type, val
      when :strv
        GLib::Strv.from val
      when :callback
        GirFFI::Builder.build_class(type_info.interface).from val
      else
        val
      end
    end
  end
end
