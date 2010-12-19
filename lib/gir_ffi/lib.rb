require 'ffi'

module GirFFI
  module Lib
    extend FFI::Library
    ffi_lib "girepository-1.0"

    # IRepository
    enum :IRepositoryLoadFlags, [:LAZY, (1<<0)]

    attach_function :g_irepository_get_default, [], :pointer
    attach_function :g_irepository_require,
      [:pointer, :string, :string, :IRepositoryLoadFlags, :pointer],
      :pointer
    attach_function :g_irepository_get_n_infos, [:pointer, :string], :int
    attach_function :g_irepository_get_info,
      [:pointer, :string, :int], :pointer
    attach_function :g_irepository_find_by_name,
      [:pointer, :string, :string], :pointer
    attach_function :g_irepository_get_shared_library,
      [:pointer, :string], :string

    # IBaseInfo
    enum :IInfoType, [
      :invalid,
      :function,
      :callback,
      :struct,
      :boxed,
      :enum,
      :flags,
      :object,
      :interface,
      :constant,
      :error_domain,
      :union,
      :value,
      :signal,
      :vfunc,
      :property,
      :field,
      :arg,
      :type,
      :unresolved
    ]

    attach_function :g_base_info_get_type, [:pointer], :IInfoType
    attach_function :g_base_info_get_name, [:pointer], :string
    attach_function :g_base_info_get_namespace, [:pointer], :string
    attach_function :g_base_info_is_deprecated, [:pointer], :bool
    attach_function :g_base_info_equal, [:pointer, :pointer], :bool

    # IFunctionInfo
    attach_function :g_function_info_get_symbol, [:pointer], :string
    # TODO: return type is bitfield
    attach_function :g_function_info_get_flags, [:pointer], :int

    # ICallableInfo
    enum :ITransfer, [
      :nothing,
      :container,
      :everything
    ]

    attach_function :g_callable_info_get_return_type, [:pointer], :pointer
    attach_function :g_callable_info_get_caller_owns, [:pointer], :ITransfer
    attach_function :g_callable_info_may_return_null, [:pointer], :bool
    attach_function :g_callable_info_get_n_args, [:pointer], :int
    attach_function :g_callable_info_get_arg, [:pointer, :int], :pointer

    # IArgInfo
    enum :IDirection, [
      :in,
      :out,
      :inout
    ]

    enum :IScopeType, [
      :invalid,
      :call,
      :async,
      :notified
    ]

    attach_function :g_arg_info_get_direction, [:pointer], :IDirection
    attach_function :g_arg_info_is_return_value, [:pointer], :bool
    attach_function :g_arg_info_is_optional, [:pointer], :bool
    attach_function :g_arg_info_may_be_null, [:pointer], :bool
    attach_function :g_arg_info_get_ownership_transfer, [:pointer], :ITransfer
    attach_function :g_arg_info_get_scope, [:pointer], :IScopeType
    attach_function :g_arg_info_get_closure, [:pointer], :int
    attach_function :g_arg_info_get_destroy, [:pointer], :int
    attach_function :g_arg_info_get_type, [:pointer], :pointer

    # The values of ITypeTag were changed in an incompatible way between
    # gobject-introspection version 0.9.0 and 0.9.1. Therefore, we need to
    # retrieve the correct values before declaring the ITypeTag enum.
    attach_function :tmp_type_tag_to_string, :g_type_tag_to_string, [:int], :string
    arr = (0..31).map { |i| [tmp_type_tag_to_string(i).to_sym, i] }.flatten
    enum :ITypeTag, arr

    # Now, attach g_type_tag_to_string again under its own name with an
    # improved signature.
    attach_function :g_type_tag_to_string, [:ITypeTag], :string

    #define G_TYPE_TAG_IS_BASIC(tag) (tag < GI_TYPE_TAG_ARRAY)

    attach_function :g_type_info_is_pointer, [:pointer], :bool
    attach_function :g_type_info_get_tag, [:pointer], :ITypeTag
    attach_function :g_type_info_get_param_type, [:pointer, :int], :pointer
    attach_function :g_type_info_get_interface, [:pointer], :pointer
    attach_function :g_type_info_get_array_length, [:pointer], :int
    attach_function :g_type_info_get_array_fixed_size, [:pointer], :int
    attach_function :g_type_info_is_zero_terminated, [:pointer], :bool
    attach_function :g_type_info_get_n_error_domains, [:pointer], :int
    attach_function :g_type_info_get_error_domain, [:pointer, :int], :pointer

    # IStructInfo
    attach_function :g_struct_info_get_n_fields, [:pointer], :int
    attach_function :g_struct_info_get_field, [:pointer, :int], :pointer
    attach_function :g_struct_info_get_n_methods, [:pointer], :int
    attach_function :g_struct_info_get_method, [:pointer, :int], :pointer
    attach_function :g_struct_info_find_method, [:pointer, :string], :pointer
    attach_function :g_struct_info_get_size, [:pointer], :int
    attach_function :g_struct_info_get_alignment, [:pointer], :int
    attach_function :g_struct_info_is_gtype_struct, [:pointer], :bool

    # IValueInfo
    attach_function :g_value_info_get_value, [:pointer], :long

    # IFieldInfo
    enum :IFieldInfoFlags, [
      :readable, (1 << 0),
      :writable, (1 << 1)
    ]
    attach_function :g_field_info_get_flags, [:pointer], :IFieldInfoFlags
    attach_function :g_field_info_get_size, [:pointer], :int
    attach_function :g_field_info_get_offset, [:pointer], :int
    attach_function :g_field_info_get_type, [:pointer], :pointer

    # IUnionInfo
    attach_function :g_union_info_get_n_fields, [:pointer], :int
    attach_function :g_union_info_get_field, [:pointer, :int], :pointer
    attach_function :g_union_info_get_n_methods, [:pointer], :int
    attach_function :g_union_info_get_method, [:pointer, :int], :pointer
    attach_function :g_union_info_find_method, [:pointer, :string], :pointer
    attach_function :g_union_info_get_size, [:pointer], :int
    attach_function :g_union_info_get_alignment, [:pointer], :int
 
    # IRegisteredTypeInfo
    attach_function :g_registered_type_info_get_type_name, [:pointer], :string
    attach_function :g_registered_type_info_get_type_init, [:pointer], :string
    attach_function :g_registered_type_info_get_g_type, [:pointer], :size_t

    # IEnumInfo
    attach_function :g_enum_info_get_storage_type, [:pointer], :ITypeTag
    attach_function :g_enum_info_get_n_values, [:pointer], :int
    attach_function :g_enum_info_get_value, [:pointer, :int], :pointer

    # IObjectInfo
    attach_function :g_object_info_get_type_name, [:pointer], :string
    attach_function :g_object_info_get_type_init, [:pointer], :string
    attach_function :g_object_info_get_abstract, [:pointer], :bool
    attach_function :g_object_info_get_parent, [:pointer], :pointer
    attach_function :g_object_info_get_n_interfaces, [:pointer], :int
    attach_function :g_object_info_get_interface, [:pointer, :int], :pointer
    attach_function :g_object_info_get_n_fields, [:pointer], :int
    attach_function :g_object_info_get_field, [:pointer, :int], :pointer
    attach_function :g_object_info_get_n_properties, [:pointer], :int
    attach_function :g_object_info_get_property, [:pointer, :int], :pointer
    attach_function :g_object_info_get_n_methods, [:pointer], :int
    attach_function :g_object_info_get_method, [:pointer, :int], :pointer
    attach_function :g_object_info_find_method, [:pointer, :string], :pointer
    attach_function :g_object_info_get_n_signals, [:pointer], :int
    attach_function :g_object_info_get_signal, [:pointer, :int], :pointer
    attach_function :g_object_info_get_n_vfuncs, [:pointer], :int
    attach_function :g_object_info_get_vfunc, [:pointer, :int], :pointer
    attach_function :g_object_info_find_vfunc, [:pointer, :string], :pointer
    attach_function :g_object_info_get_n_constants, [:pointer], :int
    attach_function :g_object_info_get_constant, [:pointer, :int], :pointer
    attach_function :g_object_info_get_class_struct, [:pointer], :pointer

    # IVFuncInfo

    enum :IVFuncInfoFlags, [
      :must_chain_up, (1 << 0),
      :must_override, (1 << 1),
      :must_not_override, (1 << 2)
    ]

    attach_function :g_vfunc_info_get_flags, [:pointer], :IVFuncInfoFlags
    attach_function :g_vfunc_info_get_offset, [:pointer], :int
    attach_function :g_vfunc_info_get_signal, [:pointer], :pointer
    attach_function :g_vfunc_info_get_invoker, [:pointer], :pointer

    # IInterfaceInfo
    attach_function :g_interface_info_get_n_prerequisites, [:pointer], :int
    attach_function :g_interface_info_get_prerequisite, [:pointer, :int], :pointer
    attach_function :g_interface_info_get_n_properties, [:pointer], :int
    attach_function :g_interface_info_get_property, [:pointer, :int], :pointer
    attach_function :g_interface_info_get_n_methods, [:pointer], :int
    attach_function :g_interface_info_get_method, [:pointer, :int], :pointer
    attach_function :g_interface_info_find_method, [:pointer, :string], :pointer
    attach_function :g_interface_info_get_n_signals, [:pointer], :int
    attach_function :g_interface_info_get_signal, [:pointer, :int], :pointer
    attach_function :g_interface_info_get_n_vfuncs, [:pointer], :int
    attach_function :g_interface_info_get_vfunc, [:pointer, :int], :pointer
    attach_function :g_interface_info_find_vfunc, [:pointer, :string], :pointer
    attach_function :g_interface_info_get_n_constants, [:pointer], :int
    attach_function :g_interface_info_get_constant, [:pointer, :int], :pointer
    attach_function :g_interface_info_get_iface_struct, [:pointer], :pointer
    
  end
end
