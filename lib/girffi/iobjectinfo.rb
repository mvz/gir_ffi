module GirFFI
  # Wraps a GIObjectInfo struct.
  # Represents an object.
  class IObjectInfo < IRegisteredTypeInfo
    def type_name; Lib.g_object_info_get_type_name @gobj; end
    def type_init; Lib.g_object_info_get_type_init @gobj; end
    def abstract?; Lib.g_object_info_get_abstract @gobj; end
    def parent; IObjectInfo.wrap(Lib.g_object_info_get_parent @gobj); end

    def n_interfaces; Lib.g_object_info_get_n_interfaces @gobj; end
    def interface index; IInterfaceInfo.wrap(Lib.g_object_info_get_interface @gobj, index); end
    build_array_method :interface

    def n_fields; Lib.g_object_info_get_n_fields @gobj; end
    def field index; IFieldInfo.wrap(Lib.g_object_info_get_field @gobj, index); end
    build_array_method :field

    def n_properties; Lib.g_object_info_get_n_properties @gobj; end
    def property index; IPropertyInfo.wrap(Lib.g_object_info_get_property @gobj, index); end
    build_array_method :property, :properties

    def n_methods; Lib.g_object_info_get_n_methods @gobj; end
    def method index; IFunctionInfo.wrap(Lib.g_object_info_get_method @gobj, index); end
    build_array_method :method

    def find_method name; IFunctionInfo.wrap(Lib.g_object_info_find_method @gobj, name); end

    def n_signals; Lib.g_object_info_get_n_signals @gobj; end
    def signal index; ISignalInfo.wrap(Lib.g_object_info_get_signal @gobj, index); end
    build_array_method :signal

    def n_vfuncs; Lib.g_object_info_get_n_vfuncs @gobj; end
    def vfunc index; IVFuncInfo.wrap(Lib.g_object_info_get_vfunc @gobj, index); end
    def find_vfunc; IVFuncInfo.wrap(Lib.g_object_info_find_vfunc @gobj); end
    build_array_method :vfunc

    def n_constants; Lib.g_object_info_get_n_constants @gobj; end
    def constant index; IConstantInfo.wrap(Lib.g_object_info_get_constant @gobj, index); end
    build_array_method :constant

    def class_struct; IStructInfo.wrap(Lib.g_object_info_get_class_struct @gobj); end
  end
end
