require 'singleton'
require 'girffi/lib'
require 'girffi/gtype'
require 'girffi/ibaseinfo'
require 'girffi/icallableinfo'
require 'girffi/icallbackinfo'
require 'girffi/ifunctioninfo'
require 'girffi/iconstantinfo'
require 'girffi/ifieldinfo'
require 'girffi/iregisteredtypeinfo'
require 'girffi/iinterfaceinfo'
require 'girffi/ipropertyinfo'
require 'girffi/ivfuncinfo'
require 'girffi/isignalinfo'
require 'girffi/iobjectinfo'
require 'girffi/istructinfo'
require 'girffi/ivalueinfo'
require 'girffi/iunioninfo'
require 'girffi/ienuminfo'
require 'girffi/iflagsinfo'

module GirFFI
  # The Gobject Introspection Repository. This class is the point of
  # access to the introspection typelibs.
  # This class wraps the GIRepository struct.
  class IRepository
    TYPEMAP = {
      #:invalid,
      :function => IFunctionInfo,
      :callback => ICallbackInfo,
      :struct => IStructInfo,
      #:boxed => ,
      :enum => IEnumInfo,
      :flags => IFlagsInfo,
      :object => IObjectInfo,
      :interface => IInterfaceInfo,
      :constant => IConstantInfo,
      # :error_domain,
      :union => IUnionInfo,
      :value => IValueInfo,
      :signal => ISignalInfo,
      :vfunc => IVFuncInfo,
      :property => IPropertyInfo,
      :field => IFieldInfo,
      :arg => IArgInfo,
      :type => ITypeInfo,
      #:unresolved
    }

    def initialize
      GType.init
      @gobj = Lib::g_irepository_get_default
    end

    include Singleton

    def self.default
      self.instance
    end

    def self.type_tag_to_string type
      Lib.g_type_tag_to_string type
    end

    def n_infos namespace
      Lib.g_irepository_get_n_infos @gobj, namespace
    end

    def require namespace, version
      err = FFI::MemoryPointer.new :pointer
      res = Lib.g_irepository_require @gobj, namespace, version, 0, err
      unless err.read_pointer.null?
	# TODO: Interpret err.
	raise "Unable to load namespace #{namespace}"
      end
    end

    def info namespace, index
      ptr = Lib.g_irepository_get_info @gobj, namespace, index
      return wrap ptr
    end

    def find_by_name namespace, name
      ptr = Lib.g_irepository_find_by_name @gobj, namespace, name
      return wrap ptr
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
