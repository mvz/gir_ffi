require 'singleton'
require 'gir_ffi/lib'
require 'gir_ffi/g_object'
require 'gir_ffi/g_error'
require 'gir_ffi/i_base_info'
require 'gir_ffi/i_callable_info'
require 'gir_ffi/i_callback_info'
require 'gir_ffi/i_function_info'
require 'gir_ffi/i_constant_info'
require 'gir_ffi/i_field_info'
require 'gir_ffi/i_registered_type_info'
require 'gir_ffi/i_interface_info'
require 'gir_ffi/i_property_info'
require 'gir_ffi/i_vfunc_info'
require 'gir_ffi/i_signal_info'
require 'gir_ffi/i_object_info'
require 'gir_ffi/i_struct_info'
require 'gir_ffi/i_value_info'
require 'gir_ffi/i_union_info'
require 'gir_ffi/i_enum_info'
require 'gir_ffi/i_flags_info'
require 'gir_ffi/i_error_domain_info'

module GirFFI
  # The Gobject Introspection Repository. This class is the point of
  # access to the introspection typelibs.
  # This class wraps the GIRepository struct.
  class IRepository
    # Map info type to class. Default is IBaseInfo.
    TYPEMAP = {
      :invalid => IBaseInfo,
      :function => IFunctionInfo,
      :callback => ICallbackInfo,
      :struct => IStructInfo,
      # TODO: There's no GIBoxedInfo, so what does :boxed mean?
      :boxed => IBaseInfo,
      :enum => IEnumInfo,
      :flags => IFlagsInfo,
      :object => IObjectInfo,
      :interface => IInterfaceInfo,
      :constant => IConstantInfo,
      :error_domain => IErrorDomainInfo,
      :union => IUnionInfo,
      :value => IValueInfo,
      :signal => ISignalInfo,
      :vfunc => IVFuncInfo,
      :property => IPropertyInfo,
      :field => IFieldInfo,
      :arg => IArgInfo,
      :type => ITypeInfo,
      :unresolved => IBaseInfo
    }

    def initialize
      GObject.type_init
      @gobj = Lib::g_irepository_get_default
    end

    include Singleton

    def self.default
      self.instance
    end

    # TODO: Make sure GType is initialized first.
    def self.prepend_search_path path
      Lib.g_irepository_prepend_search_path path
    end

    # TODO: Make sure GType is initialized first.
    def self.type_tag_to_string type
      Lib.g_type_tag_to_string type
    end

    def require namespace, version=nil
      errpp = FFI::MemoryPointer.new(:pointer).write_pointer nil

      Lib.g_irepository_require @gobj, namespace, version, 0, errpp

      errp = errpp.read_pointer
      raise GError.new(errp)[:message] unless errp.null?
    end

    def n_infos namespace
      Lib.g_irepository_get_n_infos @gobj, namespace
    end

    def info namespace, index
      ptr = Lib.g_irepository_get_info @gobj, namespace, index
      return wrap ptr
    end

    # Utility method
    def infos namespace
      (0..(n_infos(namespace) - 1)).map do |idx|
	info namespace, idx
      end
    end

    def find_by_name namespace, name
      ptr = Lib.g_irepository_find_by_name @gobj, namespace, name
      return wrap ptr
    end

    def find_by_gtype gtype
      ptr = Lib.g_irepository_find_by_gtype @gobj, gtype
      return wrap ptr
    end

    def dependencies namespace
      strz = Lib.g_irepository_get_dependencies @gobj, namespace
      return [] if strz.null?
      arr = []
      i = 0
      loop do
        ptr = strz.get_pointer i * FFI.type_size(:pointer)
        return arr if ptr.null?
        arr << ptr.read_string
        i += 1
      end
    end

    def shared_library namespace
      Lib.g_irepository_get_shared_library @gobj, namespace
    end

    def self.wrap_ibaseinfo_pointer ptr
      return nil if ptr.null?

      type = Lib.g_base_info_get_type ptr
      klass = TYPEMAP[type]

      return klass.wrap(ptr)
    end

    private

    def wrap ptr
      IRepository.wrap_ibaseinfo_pointer ptr
    end
  end
end
