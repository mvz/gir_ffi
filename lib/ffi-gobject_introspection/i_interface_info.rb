# frozen_string_literal: true

module GObjectIntrospection
  # Wraps a IInterfaceInfo struct.
  # Represents an interface.
  class IInterfaceInfo < IRegisteredTypeInfo
    def n_prerequisites
      Lib.g_interface_info_get_n_prerequisites self
    end

    def prerequisite(index)
      IBaseInfo.wrap Lib.g_interface_info_get_prerequisite(self, index)
    end

    ##
    build_array_method :prerequisites

    def n_properties
      Lib.g_interface_info_get_n_properties self
    end

    def property(index)
      IPropertyInfo.wrap Lib.g_interface_info_get_property(self, index)
    end

    ##
    build_array_method :properties, :property
    build_finder_method :find_property, :n_properties

    def get_n_methods
      Lib.g_interface_info_get_n_methods self
    end

    def get_method(index)
      IFunctionInfo.wrap Lib.g_interface_info_get_method(self, index)
    end

    ##
    build_array_method :get_methods

    def find_method(name)
      IFunctionInfo.wrap Lib.g_interface_info_find_method(self, name.to_s)
    end

    def n_signals
      Lib.g_interface_info_get_n_signals self
    end

    def signal(index)
      ISignalInfo.wrap Lib.g_interface_info_get_signal(self, index)
    end

    ##
    build_array_method :signals
    build_finder_method :find_signal

    def n_vfuncs
      Lib.g_interface_info_get_n_vfuncs self
    end

    def vfunc(index)
      IVFuncInfo.wrap Lib.g_interface_info_get_vfunc(self, index)
    end

    ##
    build_array_method :vfuncs

    def find_vfunc(name)
      IVFuncInfo.wrap Lib.g_interface_info_find_vfunc(self, name)
    end

    def n_constants
      Lib.g_interface_info_get_n_constants self
    end

    def constant(index)
      IConstantInfo.wrap Lib.g_interface_info_get_constant(self, index)
    end

    ##
    build_array_method :constants

    def iface_struct
      IStructInfo.wrap Lib.g_interface_info_get_iface_struct(self)
    end
  end
end
