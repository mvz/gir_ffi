require 'ffi-gobject_introspection/i_base_info'
module GObjectIntrospection
  # Wraps a GIArgInfo struct.
  # Represents an argument.
  class IArgInfo < IBaseInfo
    def direction
      Lib.g_arg_info_get_direction @gobj
    end

    def return_value?
      Lib.g_arg_info_is_return_value @gobj
    end

    def optional?
      Lib.g_arg_info_is_optional @gobj
    end

    def caller_allocates?
      Lib.g_arg_info_is_caller_allocates @gobj
    end

    def may_be_null?
      Lib.g_arg_info_may_be_null @gobj
    end

    def skip?
      Lib.g_arg_info_is_skip @gobj
    end

    def ownership_transfer
      Lib.g_arg_info_get_ownership_transfer @gobj
    end

    def scope
      Lib.g_arg_info_get_scope @gobj
    end

    def closure
      Lib.g_arg_info_get_closure @gobj
    end

    def destroy
      Lib.g_arg_info_get_destroy @gobj
    end

    def argument_type
      ITypeInfo.wrap(Lib.g_arg_info_get_type @gobj)
    end
  end
end
