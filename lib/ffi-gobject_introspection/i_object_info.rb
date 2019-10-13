# frozen_string_literal: true

module GObjectIntrospection
  # Wraps a GIObjectInfo struct.
  # Represents an object.
  class IObjectInfo < IRegisteredTypeInfo
    def type_name
      Lib.g_object_info_get_type_name self
    end

    def type_init
      Lib.g_object_info_get_type_init self
    end

    def abstract?
      Lib.g_object_info_get_abstract self
    end

    def fundamental?
      Lib.g_object_info_get_fundamental self
    end

    def parent
      IObjectInfo.wrap Lib.g_object_info_get_parent(self)
    end

    def n_interfaces
      Lib.g_object_info_get_n_interfaces self
    end

    def interface(index)
      IInterfaceInfo.wrap Lib.g_object_info_get_interface(self, index)
    end

    ##
    build_array_method :interfaces

    def n_fields
      Lib.g_object_info_get_n_fields self
    end

    def field(index)
      IFieldInfo.wrap Lib.g_object_info_get_field(self, index)
    end

    ##
    build_array_method :fields

    def n_properties
      Lib.g_object_info_get_n_properties self
    end

    def property(index)
      IPropertyInfo.wrap Lib.g_object_info_get_property(self, index)
    end

    def properties
      @properties ||= Array.new(n_properties) { |idx| property(idx) }
    end

    def find_property(name)
      name = name.to_s.tr("_", "-")
      properties.find { |prop| prop.name == name }
    end

    def get_n_methods
      Lib.g_object_info_get_n_methods self
    end

    def get_method(index)
      IFunctionInfo.wrap Lib.g_object_info_get_method(self, index)
    end

    ##
    build_array_method :get_methods

    def find_method(name)
      IFunctionInfo.wrap Lib.g_object_info_find_method(self, name.to_s)
    end

    def n_signals
      Lib.g_object_info_get_n_signals self
    end

    def signal(index)
      ISignalInfo.wrap Lib.g_object_info_get_signal(self, index)
    end

    ##
    build_array_method :signals
    build_finder_method :find_signal

    def n_vfuncs
      Lib.g_object_info_get_n_vfuncs self
    end

    def vfunc(index)
      IVFuncInfo.wrap Lib.g_object_info_get_vfunc(self, index)
    end

    def find_vfunc(name)
      IVFuncInfo.wrap Lib.g_object_info_find_vfunc(self, name.to_s)
    end
    ##
    build_array_method :vfuncs

    def n_constants
      Lib.g_object_info_get_n_constants self
    end

    def constant(index)
      IConstantInfo.wrap Lib.g_object_info_get_constant(self, index)
    end
    ##
    build_array_method :constants

    def class_struct
      IStructInfo.wrap Lib.g_object_info_get_class_struct(self)
    end
  end
end
