module GIRepository
  class ITypeInfo < IBaseInfo
    def pointer?; Lib.g_type_info_is_pointer @gobj; end
    def tag; Lib.g_type_info_get_tag @gobj; end
    def param_type n; ITypeInfo.wrap(Lib.g_type_info_get_param_type @gobj, n); end
    def interface; IBaseInfo.wrap(Lib.g_type_info_get_interface @gobj); end
    def array_length; Lib.g_type_info_get_array_length @gobj; end
    def array_fixed_size; Lib.g_type_info_get_array_fixed_size @gobj; end
    def zero_terminated?; Lib.g_type_info_is_zero_terminated @gobj; end
    def n_error_domains; Lib.g_type_info_get_n_error_domains @gobj; end
    def error_domain n; IErrorDomainInfo.wrap(Lib.g_type_info_get_error_domain @gobj, n); end
    build_array_method :error_domain
    def name
      raise "Should not call this for gir 0.6.5 ..."
    end
  end
end

