require 'girffi/ibaseinfo'
require 'girffi/itypeinfo'
require 'girffi/iarginfo'

module GirFFI
  class ICallableInfo < IBaseInfo
    def return_type; ITypeInfo.wrap(Lib.g_callable_info_get_return_type @gobj); end
    def caller_owns; Lib.g_callable_info_get_caller_owns @gobj; end
    def may_return_null?; Lib.g_callable_info_may_return_null @gobj; end
    def n_args; Lib.g_callable_info_get_n_args @gobj; end
    def arg n; IArgInfo.wrap(Lib.g_callable_info_get_arg @gobj, n); end
    build_array_method :arg
  end
end

