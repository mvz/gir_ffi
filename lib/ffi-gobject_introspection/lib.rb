require 'ffi'

module GObjectIntrospection
  # Module for attaching functions from the girepository library
  module Lib
    extend FFI::Library
    ffi_lib 'girepository-1.0'

    # Helper class to support guessing the gobject-introspection version.
    # Provide several guesses to #provide_guess, and the result in #best_guess
    # will be the best (i.e., lowest) guess.
    class VersionGuesser
      def initialize base
        @guess = base
      end

      def provide_guess guessed
        @guess = guessed if guessed < @guess
      end

      def best_guess
        @guess
      end
    end

    version_guesser = VersionGuesser.new('1.42')

    # IRepository
    enum :IRepositoryLoadFlags, [:LAZY, (1 << 0)]

    attach_function :g_irepository_get_default, [], :pointer
    attach_function :g_irepository_prepend_search_path, [:string], :void
    attach_function :g_irepository_require,
                    [:pointer, :string, :string, :IRepositoryLoadFlags, :pointer],
                    :pointer
    attach_function :g_irepository_get_version, [:pointer, :string], :string

    attach_function :g_irepository_get_n_infos, [:pointer, :string], :int
    attach_function :g_irepository_get_info, [:pointer, :string, :int], :pointer
    attach_function :g_irepository_find_by_name, [:pointer, :string, :string], :pointer
    attach_function :g_irepository_find_by_gtype, [:pointer, :size_t], :pointer
    attach_function :g_irepository_get_dependencies, [:pointer, :string], :pointer
    attach_function :g_irepository_get_shared_library, [:pointer, :string], :string

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
      :invalid_was_error_domain, # deprecated in GI 1.29.17
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

    attach_function :g_base_info_ref, [:pointer], :void
    attach_function :g_base_info_unref, [:pointer], :void
    attach_function :g_base_info_get_type, [:pointer], :IInfoType
    attach_function :g_base_info_get_name, [:pointer], :string
    attach_function :g_base_info_get_namespace, [:pointer], :string
    attach_function :g_base_info_get_container, [:pointer], :pointer
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
    attach_function :g_callable_info_skip_return, [:pointer], :bool

    begin
      attach_function :g_callable_info_get_instance_ownership_transfer,
                      [:pointer], :ITransfer
    rescue FFI::NotFoundError
      version_guesser.provide_guess '1.40'
    end

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
    attach_function :g_arg_info_is_caller_allocates, [:pointer], :bool
    attach_function :g_arg_info_is_skip, [:pointer], :bool
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
    type_tag_map = (0..31).map { |id|
      sym = tmp_type_tag_to_string(id).to_sym
      if sym == :unknown
        nil
      else
        [sym, id]
      end
    }.compact.flatten
    enum :ITypeTag, type_tag_map

    # Now, attach g_type_tag_to_string again under its own name with an
    # improved signature.
    attach_function :g_type_tag_to_string, [:ITypeTag], :string

    enum :IArrayType, [
      :c,
      :array,
      :ptr_array,
      :byte_array
    ]

    attach_function :g_type_info_is_pointer, [:pointer], :bool
    attach_function :g_type_info_get_tag, [:pointer], :ITypeTag
    attach_function :g_type_info_get_param_type, [:pointer, :int], :pointer
    attach_function :g_type_info_get_interface, [:pointer], :pointer
    attach_function :g_type_info_get_array_length, [:pointer], :int
    attach_function :g_type_info_get_array_fixed_size, [:pointer], :int
    attach_function :g_type_info_get_array_type, [:pointer], :IArrayType
    attach_function :g_type_info_is_zero_terminated, [:pointer], :bool

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
    # TODO: return type is bitfield :IFieldInfoFlags
    attach_function :g_field_info_get_flags, [:pointer], :int
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
    attach_function :g_enum_info_get_n_methods, [:pointer], :int
    attach_function :g_enum_info_get_method, [:pointer, :int], :pointer

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
    attach_function :g_object_info_get_fundamental, [:pointer], :bool

    # IVFuncInfo

    attach_function :g_vfunc_info_get_flags, [:pointer], :int
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

    # Union type representing an argument value
    class GIArgument < FFI::Union
      signed_size_t = "int#{FFI.type_size(:size_t) * 8}".to_sym

      layout :v_boolean, :int,
             :v_int8, :int8,
             :v_uint8, :uint8,
             :v_int16, :int16,
             :v_uint16, :uint16,
             :v_int32, :int32,
             :v_uint32, :uint32,
             :v_int64, :int64,
             :v_uint64, :uint64,
             :v_float, :float,
             :v_double, :double,
             :v_short, :short,
             :v_ushort, :ushort,
             :v_int, :int,
             :v_uint, :uint,
             :v_long, :long,
             :v_ulong, :ulong,
             :v_ssize, signed_size_t,
             :v_size, :size_t,
             :v_string, :string,
             :v_pointer, :pointer
    end

    # IConstInfo
    #
    attach_function :g_constant_info_get_type, [:pointer], :pointer
    attach_function :g_constant_info_get_value, [:pointer, :pointer], :int

    # IPropertyInfo
    #
    attach_function :g_property_info_get_type, [:pointer], :pointer

    ::GObjectIntrospection::VERSION = version_guesser.best_guess
  end
end
