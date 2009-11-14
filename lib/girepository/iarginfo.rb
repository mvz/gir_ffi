require 'girepository/ibaseinfo'
module GIRepository
  class IArgInfo < IBaseInfo
    def direction; g_arg_info_get_direction @gobj; end
    def dipper?; g_arg_info_is_dipper @gobj; end
    def return_value?; g_arg_info_is_return_value @gobj; end
    def optional?; g_arg_info_is_optional @gobj; end
    def may_be_null?; g_arg_info_may_be_null @gobj; end
    def ownership_transfer; g_arg_info_get_ownership_transfer @gobj; end
    def scope; g_arg_info_get_scope @gobj; end
    def closure; g_arg_info_get_closure @gobj; end
    def destroy; g_arg_info_get_destroy @gobj; end
    def type; ITypeInfo.wrap(g_arg_info_get_type @gobj); end
  end
end
