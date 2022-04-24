# frozen_string_literal: true

require "gir_ffi/property_not_found_error"

GObject.load_class :Object

module GObject
  # Overrides for GObject, GObject's generic base class.
  class Object
    GObject::Lib.attach_function(:g_object_new_with_properties,
                                 [:size_t, :uint32, :pointer, :pointer],
                                 :pointer)

    def self.new_with_properties(*args, &block)
      obj = allocate
      obj.__send__ :initialize_with_properties, *args, &block
      obj
    end

    # Starting with GLib 2.54.0, use g_object_new_with_properties, which
    # takes an array of names and an array of values.
    def initialize_with_properties(properties = {})
      names, gvalues = names_and_gvalues_for_properties(properties)

      n_properties = names.length
      names_arr = GirFFI::SizedArray.from(:utf8, -1, names)
      gvalues_arr = GirFFI::SizedArray.from(GObject::Value, -1, gvalues)

      ptr = GObject::Lib.g_object_new_with_properties(self.class.gtype,
                                                      n_properties,
                                                      names_arr,
                                                      gvalues_arr)
      store_pointer ptr
    end

    alias old_initialze initialize
    alias initialize initialize_with_properties
    remove_method :old_initialze

    def self.new(*args, &block)
      obj = allocate
      obj.__send__ :initialize, *args, &block
      obj
    end

    alias base_initialize initialize

    private :base_initialize

    remove_method :ref

    def ref
      Lib.g_object_ref self
      self
    end

    def self.make_finalizer(ptr)
      proc { finalize ptr }
    end

    class << self
      protected

      def finalize(ptr)
        rc = GObject::Object::Struct.new(ptr)[:ref_count]
        if rc == 0
          warn "not unreffing #{name}:#{ptr} (#{rc})"
        else
          GObject::Lib.g_object_unref ptr
        end
      end
    end

    def signal_connect(event, data = nil, &block)
      GObject.signal_connect(self, event, data, &block)
    end

    def signal_connect_after(event, data = nil, &block)
      GObject.signal_connect_after(self, event, data, &block)
    end

    setup_instance_method! "get_property"
    setup_instance_method! "set_property"
    setup_instance_method! "is_floating"
    alias floating? is_floating

    private

    def store_pointer(ptr)
      super
      make_finalizer
    end

    def make_finalizer
      ObjectSpace.define_finalizer self, self.class.make_finalizer(struct.to_ptr)
    end

    def names_and_gvalues_for_properties(properties)
      return [], [] unless properties.any?

      properties.map do |name, value|
        name = name.to_s
        gvalue = gvalue_for_property(name)
        gvalue.set_value value

        [name, gvalue]
      end.transpose
    end

    def gvalue_for_property(property_name)
      gtype = property_gtype property_name
      GObject::Value.for_gtype gtype
    end

    def property_gtype(property_name)
      property_param_spec(property_name).value_type
    end

    def property_param_spec(property_name)
      class_struct.find_property property_name or
        raise GirFFI::PropertyNotFoundError.new(property_name, self.class)
    end

    # Overrides for GObject, GObject's generic base class.
    module Overrides
      def get_property(property_name)
        gvalue = gvalue_for_property property_name
        super property_name, gvalue
        value = gvalue.get_value

        type_info = get_property_type property_name
        value = property_value_post_conversion(value, type_info) if type_info

        value
      end

      def set_property(property_name, value)
        type_info = get_property_type property_name
        value = property_value_pre_conversion(value, type_info) if type_info

        gvalue = gvalue_for_property(property_name)
        gvalue.set_value value

        super property_name, gvalue
      end

      private

      def get_property_type(property_name)
        self.class.find_property(property_name)&.property_type
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
        when :byte_array
          GLib::ByteArray.from val
        when :callback
          GirFFI::Builder.build_class(type_info.interface).from val
        else
          val
        end
      end
    end

    prepend Overrides
  end
end
