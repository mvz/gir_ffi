# frozen_string_literal: true

module GirFFI
  # Represents a property of a user defined type. Wraps a GParamSpec with
  # useful helper methods for building property accessors etc.
  class UserDefinedPropertyInfo
    # Type info for user-defined property
    class UserDefinedTypeInfo
      include InfoExt::ITypeInfo

      def initialize(param_spec)
        @param_spec = param_spec
      end

      # TODO: Unify with InfoExt::ITypeInfo.flattened_tag_to_gtype_map
      G_TYPE_TAG_MAP = {
        GObject::TYPE_BOOLEAN => :gboolean,
        GObject::TYPE_CHAR    => :gint8,
        GObject::TYPE_UCHAR   => :guint8,
        GObject::TYPE_FLOAT   => :gfloat,
        GObject::TYPE_DOUBLE  => :gdouble,
        GObject::TYPE_INT     => :gint,
        GObject::TYPE_UINT    => :guint,
        GObject::TYPE_LONG    => :glong,
        GObject::TYPE_ULONG   => :gulong,
        GObject::TYPE_INT64   => :gint64,
        GObject::TYPE_UINT64  => :guint64,
        GObject::TYPE_ENUM    => :interface,
        GObject::TYPE_FLAGS   => :interface,
        GObject::TYPE_STRING  => :utf8,
        GObject::TYPE_BOXED   => :interface,
        GObject::TYPE_OBJECT  => :interface
      }.freeze

      def tag
        @tag ||= G_TYPE_TAG_MAP.fetch(fundamental_value_type)
      end

      # TODO: Unify with InfoExt::ITypeInfo.flattened_tag_to_gtype_map
      G_TYPE_POINTER_MAP = {
        GObject::TYPE_BOOLEAN => false,
        GObject::TYPE_CHAR    => false,
        GObject::TYPE_UCHAR   => false,
        GObject::TYPE_FLOAT   => false,
        GObject::TYPE_DOUBLE  => false,
        GObject::TYPE_INT     => false,
        GObject::TYPE_UINT    => false,
        GObject::TYPE_LONG    => false,
        GObject::TYPE_ULONG   => false,
        GObject::TYPE_INT64   => false,
        GObject::TYPE_UINT64  => false,
        GObject::TYPE_ENUM    => false,
        GObject::TYPE_FLAGS   => false,
        GObject::TYPE_STRING  => true,
        GObject::TYPE_BOXED   => true,
        GObject::TYPE_OBJECT  => true
      }.freeze

      def pointer?
        G_TYPE_POINTER_MAP.fetch(fundamental_value_type)
      end

      G_TYPE_INTERFACE_TAG_MAP = {
        GObject::TYPE_ENUM   => :enum,
        GObject::TYPE_FLAGS  => :flags,
        GObject::TYPE_BOXED  => :struct,
        GObject::TYPE_OBJECT => :object
      }.freeze

      def interface_type
        G_TYPE_INTERFACE_TAG_MAP.fetch(fundamental_value_type) if interface?
      end

      def hidden_struct_type?
        false
      end

      def interface_class
        @interface_class ||= Builder.build_by_gtype(value_type) if interface?
      end

      def interface_class_name
        interface_class.name if interface?
      end

      def ffi_type
        GirFFI::TypeMap.map_basic_type(tag)
      end

      private

      def value_type
        @param_spec.value_type
      end

      def fundamental_value_type
        @fundamental_value_type ||= GObject.type_fundamental value_type
      end

      def interface?
        tag == :interface
      end
    end

    def initialize(param_spec, container, offset)
      @param_spec = param_spec
      @container = container
      @offset = offset
    end

    attr_reader :container, :offset, :param_spec

    def name
      @param_spec.accessor_name
    end

    def field_type
      @field_type ||= UserDefinedTypeInfo.new @param_spec
    end

    def related_array_length_field
      nil
    end

    def writable?
      param_spec.flags[:writable]
    end

    def ffi_type
      field_type.ffi_type
    end

    def field_symbol
      name.to_sym
    end
  end
end
