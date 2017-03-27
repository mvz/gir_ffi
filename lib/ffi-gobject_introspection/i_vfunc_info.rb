# frozen_string_literal: true

module GObjectIntrospection
  # Wraps a GIVFuncInfo struct.
  # Represents a virtual function.
  class IVFuncInfo < ICallableInfo
    def flags
      Lib.g_vfunc_info_get_flags self
    end

    def throws?
      flags.fetch :throws
    end

    def invoker
      IFunctionInfo.wrap Lib.g_vfunc_info_get_invoker self
    end
  end
end
