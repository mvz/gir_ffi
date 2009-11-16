require 'girepository/ibaseinfo'
require 'girepository/ifieldinfo'
require 'girepository/ivfuncinfo'

module GIRepository
  class IObjectInfo < IBaseInfo
    def type_name; Lib.g_object_info_get_type_name @gobj; end
    def type_init; Lib.g_object_info_get_type_init @gobj; end
    def abstract?; Lib.g_object_info_get_abstract @gobj; end
    def parent; IObjectInfo.wrap(Lib.g_object_info_get_parent @gobj); end

    def n_interfaces; Lib.g_object_info_get_n_interfaces @gobj; end
    def interface i; IInterfaceInfo.wrap(Lib.g_object_info_get_interface @gobj, i); end
    build_array_method :interface

    def n_fields; Lib.g_object_info_get_n_fields @gobj; end
    def field i; IFieldInfo.wrap(Lib.g_object_info_get_field @gobj, i); end
    build_array_method :field

    def n_properties; Lib.g_object_info_get_n_properties @gobj; end
    def property i; IPropertyInfo.wrap(Lib.g_object_info_get_property @gobj, i); end
    build_array_method :property, :properties

    def n_methods; Lib.g_object_info_get_n_methods @gobj; end
    def method i; IFunctionInfo.wrap(Lib.g_object_info_get_method @gobj, i); end
    def find_method; IFunctionInfo.wrap(Lib.g_object_info_find_method @gobj); end
    build_array_method :method

    def n_signals; Lib.g_object_info_get_n_signals @gobj; end
    def signal i; ISignalInfo.wrap(Lib.g_object_info_get_signal @gobj, i); end
    build_array_method :signal

    def n_vfuncs; Lib.g_object_info_get_n_vfuncs @gobj; end
    def vfunc i; IVFuncInfo.wrap(Lib.g_object_info_get_vfunc @gobj, i); end
    def find_vfunc; IVFuncInfo.wrap(Lib.g_object_info_find_vfunc @gobj); end
    build_array_method :vfunc

    def n_constants; Lib.g_object_info_get_n_constants @gobj; end
    def constant i; IConstantInfo.wrap(Lib.g_object_info_get_constant @gobj, i); end
    build_array_method :constant

    def class_struct; IStructInfo.wrap(Lib.g_object_info_get_class_struct @gobj); end
  end
end
