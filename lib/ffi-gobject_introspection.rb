# frozen_string_literal: true

require "ffi-gobject_introspection/gobject_type_init"
GObjectIntrospection::GObjectTypeInit.type_init

require "ffi-gobject_introspection/i_base_info"
require "ffi-gobject_introspection/i_callable_info"
require "ffi-gobject_introspection/i_callback_info"
require "ffi-gobject_introspection/i_function_info"
require "ffi-gobject_introspection/i_constant_info"
require "ffi-gobject_introspection/i_field_info"
require "ffi-gobject_introspection/i_registered_type_info"
require "ffi-gobject_introspection/i_interface_info"
require "ffi-gobject_introspection/i_property_info"
require "ffi-gobject_introspection/i_vfunc_info"
require "ffi-gobject_introspection/i_signal_info"
require "ffi-gobject_introspection/i_object_info"
require "ffi-gobject_introspection/i_struct_info"
require "ffi-gobject_introspection/i_value_info"
require "ffi-gobject_introspection/i_union_info"
require "ffi-gobject_introspection/i_enum_info"
require "ffi-gobject_introspection/i_flags_info"
require "ffi-gobject_introspection/i_unresolved_info"

module GObjectIntrospection
  # Map info type to class. Default is IBaseInfo.
  TYPEMAP = {
    invalid: IBaseInfo,
    function: IFunctionInfo,
    callback: ICallbackInfo,
    struct: IStructInfo,
    # TODO: There's no GIBoxedInfo, so what does :boxed mean?
    boxed: IBaseInfo,
    enum: IEnumInfo,
    flags: IFlagsInfo,
    object: IObjectInfo,
    interface: IInterfaceInfo,
    constant: IConstantInfo,
    invalid_was_error_domain: IBaseInfo,
    union: IUnionInfo,
    value: IValueInfo,
    signal: ISignalInfo,
    vfunc: IVFuncInfo,
    property: IPropertyInfo,
    field: IFieldInfo,
    arg: IArgInfo,
    type: ITypeInfo,
    unresolved: IUnresolvedInfo
  }.freeze
end

require "ffi-gobject_introspection/i_repository"
