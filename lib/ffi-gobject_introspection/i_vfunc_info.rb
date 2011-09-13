module GObjectIntrospection
  # Wraps a GIVFuncInfo struct.
  # Represents a virtual function.
  class IVFuncInfo < IBaseInfo
    def flags
      Lib.g_vfunc_info_get_flags @gobj
    end
    def offset
      Lib.g_vfunc_info_get_offset @gobj
    end
    def signal
      ISignalInfo.wrap(Lib.g_vfunc_info_get_signal @gobj)
    end
    def invoker
      IFunctionInfo.wrap(Lib.g_vfunc_info_get_invoker @gobj)
    end
  end
end
