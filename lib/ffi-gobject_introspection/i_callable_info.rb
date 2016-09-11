# frozen_string_literal: true
require 'ffi-gobject_introspection/i_base_info'
require 'ffi-gobject_introspection/i_type_info'
require 'ffi-gobject_introspection/i_arg_info'

module GObjectIntrospection
  # Wraps a GICallableInfo struct; represents a callable, either
  # IFunctionInfo, ICallbackInfo or IVFuncInfo.
  class ICallableInfo < IBaseInfo
    def return_type
      ITypeInfo.wrap Lib.g_callable_info_get_return_type(@gobj)
    end

    def caller_owns
      Lib.g_callable_info_get_caller_owns @gobj
    end

    def may_return_null?
      Lib.g_callable_info_may_return_null @gobj
    end

    def can_throw_gerror?
      Lib.g_callable_info_can_throw_gerror @gobj
    end

    def n_args
      Lib.g_callable_info_get_n_args @gobj
    end

    def arg(index)
      IArgInfo.wrap Lib.g_callable_info_get_arg(@gobj, index)
    end
    ##
    build_array_method :args

    def skip_return?
      Lib.g_callable_info_skip_return @gobj
    end

    def instance_ownership_transfer
      Lib.g_callable_info_get_instance_ownership_transfer @gobj
    end
  end
end
