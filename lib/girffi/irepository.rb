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
    @@singleton = nil

    def self.default
      if @@singleton.nil?
	GType.init
	@@singleton = new(Lib::g_irepository_get_default)
      end
      @@singleton
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
      unless err.get_pointer(0).address == 0
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

    private_class_method :new

    def initialize(gobject)
      @gobj = gobject
    end

    def self.wrap_ibaseinfo_pointer ptr
      return nil if ptr.null?
      type = Lib.g_base_info_get_type ptr
      # TODO: Perhaps use a hash or something as a typemap.
      case type
      when :object
	return IObjectInfo.new(ptr)
      when :function
	return IFunctionInfo.new(ptr)
      when :callback
	return ICallbackInfo.new(ptr)
      when :interface
	return IInterfaceInfo.new(ptr)
      when :struct
	return IStructInfo.new(ptr)
      when :constant
	return IConstantInfo.new(ptr)
      when :union
	return IUnionInfo.new(ptr)
      when :enum
	return IEnumInfo.new(ptr)
      when :flags
	return IFlagsInfo.new(ptr)
      else
	raise "Returning base info object for #{type}"
	return IBaseInfo.new(ptr)
      end
    end

    private

    def wrap ptr
      IRepository.wrap_ibaseinfo_pointer ptr
    end
  end
end
