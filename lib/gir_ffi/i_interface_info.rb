module GirFFI
  # Wraps a IInterfaceInfo struct.
  # Represents an interface.
  class IInterfaceInfo < IRegisteredTypeInfo
    def n_prerequisites
      Lib.g_interface_info_get_n_prerequisites @gobj
    end
    def prerequisite index
      IBaseInfo.wrap(Lib.g_interface_info_get_prerequisite @gobj, index)
    end
    ##
    build_array_method :prerequisites

    def n_properties
      Lib.g_interface_info_get_n_properties @gobj
    end
    def property index
      IPropertyInfo.wrap(Lib.g_interface_info_get_property @gobj, index)
    end
    ##
    build_array_method :properties, :property

    def get_n_methods
      Lib.g_interface_info_get_n_methods @gobj
    end
    def get_method index
      IFunctionInfo.wrap(Lib.g_interface_info_get_method @gobj, index)
    end
    ##
    build_array_method :get_methods

    def find_method name
      IFunctionInfo.wrap(Lib.g_interface_info_find_method @gobj, name)
    end

    def n_signals
      Lib.g_interface_info_get_n_signals @gobj
    end
    def signal index
      ISignalInfo.wrap(Lib.g_interface_info_get_signal @gobj, index)
    end
    ##
    build_array_method :signals

    def n_vfuncs
      Lib.g_interface_info_get_n_vfuncs @gobj
    end
    def vfunc index
      IVFuncInfo.wrap(Lib.g_interface_info_get_vfunc @gobj, index)
    end
    ##
    build_array_method :vfuncs

    def find_vfunc name
      IVFuncInfo.wrap(Lib.g_interface_info_find_vfunc @gobj, name)
    end

    def n_constants
      Lib.g_interface_info_get_n_constants @gobj
    end
    def constant index
      IConstantInfo.wrap(Lib.g_interface_info_get_constant @gobj, index)
    end
    ##
    build_array_method :constants

    def iface_struct
      IStructInfo.wrap(Lib.g_interface_info_get_iface_struct @gobj)
    end

  end
end
