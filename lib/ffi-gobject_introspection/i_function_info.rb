# frozen_string_literal: true

module GObjectIntrospection
  # Wraps a GIFunctionInfo struct.
  # Represents a function or method.
  class IFunctionInfo < ICallableInfo
    def symbol
      Lib.g_function_info_get_symbol self
    end

    def flags
      Lib.g_function_info_get_flags self
    end

    def method?
      flags[:is_method]
    end

    def constructor?
      flags[:is_constructor]
    end

    def getter?
      flags[:is_getter]
    end

    def setter?
      flags[:is_setter]
    end

    def wraps_vfunc?
      flags[:wraps_vfunc]
    end

    def throws?
      flags[:throws]
    end
  end
end
