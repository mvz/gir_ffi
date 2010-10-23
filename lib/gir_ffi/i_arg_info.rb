require 'gir_ffi/i_base_info'
module GirFFI
  # Wraps a GIArgInfo struct.
  # Represents an argument.
  class IArgInfo < IBaseInfo
    def direction; Lib.g_arg_info_get_direction @gobj; end
    def return_value?; Lib.g_arg_info_is_return_value @gobj; end
    def optional?; Lib.g_arg_info_is_optional @gobj; end
    def may_be_null?; Lib.g_arg_info_may_be_null @gobj; end
    def ownership_transfer; Lib.g_arg_info_get_ownership_transfer @gobj; end
    def scope; Lib.g_arg_info_get_scope @gobj; end
    def closure; Lib.g_arg_info_get_closure @gobj; end
    def destroy; Lib.g_arg_info_get_destroy @gobj; end
    def type; ITypeInfo.wrap(Lib.g_arg_info_get_type @gobj); end
  end
end
