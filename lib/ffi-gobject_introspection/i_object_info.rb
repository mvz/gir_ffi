module GObjectIntrospection
  # Wraps a GIObjectInfo struct.
  # Represents an object.
  class IObjectInfo < IRegisteredTypeInfo
    def type_name
      Lib.g_object_info_get_type_name @gobj
    end

    def type_init
      Lib.g_object_info_get_type_init @gobj
    end

    def abstract?
      Lib.g_object_info_get_abstract @gobj
    end

    def fundamental?
      Lib.g_object_info_get_fundamental @gobj
    end

    def parent
      IObjectInfo.wrap Lib.g_object_info_get_parent(@gobj)
    end

    def n_interfaces
      Lib.g_object_info_get_n_interfaces @gobj
    end

    def interface(index)
      IInterfaceInfo.wrap Lib.g_object_info_get_interface(@gobj, index)
    end

    ##
    build_array_method :interfaces

    def n_fields
      Lib.g_object_info_get_n_fields @gobj
    end

    def field(index)
      IFieldInfo.wrap Lib.g_object_info_get_field(@gobj, index)
    end

    ##
    build_array_method :fields

    def n_properties
      Lib.g_object_info_get_n_properties @gobj
    end

    def property(index)
      IPropertyInfo.wrap Lib.g_object_info_get_property(@gobj, index)
    end

    def properties
      @properties ||= n_properties.times.map { |idx| property(idx) }
    end

    def find_property(name)
      name = name.to_s.gsub(/_/, '-')
      properties.find { |prop| prop.name == name }
    end

    def get_n_methods
      Lib.g_object_info_get_n_methods @gobj
    end

    def get_method(index)
      IFunctionInfo.wrap Lib.g_object_info_get_method(@gobj, index)
    end

    ##
    build_array_method :get_methods

    def find_method(name)
      IFunctionInfo.wrap Lib.g_object_info_find_method(@gobj, name.to_s)
    end

    def n_signals
      Lib.g_object_info_get_n_signals @gobj
    end

    def signal(index)
      ISignalInfo.wrap Lib.g_object_info_get_signal(@gobj, index)
    end

    ##
    build_array_method :signals
    build_finder_method :find_signal

    def n_vfuncs
      Lib.g_object_info_get_n_vfuncs @gobj
    end

    def vfunc(index)
      IVFuncInfo.wrap Lib.g_object_info_get_vfunc(@gobj, index)
    end

    def find_vfunc(name)
      IVFuncInfo.wrap Lib.g_object_info_find_vfunc(@gobj, name.to_s)
    end
    ##
    build_array_method :vfuncs

    def n_constants
      Lib.g_object_info_get_n_constants @gobj
    end

    def constant(index)
      IConstantInfo.wrap Lib.g_object_info_get_constant(@gobj, index)
    end
    ##
    build_array_method :constants

    def class_struct
      IStructInfo.wrap Lib.g_object_info_get_class_struct(@gobj)
    end
  end
end
