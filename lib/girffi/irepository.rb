require 'girffi/lib'
require 'girffi/helper/gtype'
require 'girffi/ibaseinfo'
require 'girffi/icallableinfo'
require 'girffi/ifunctioninfo'
require 'girffi/iconstantinfo'
require 'girffi/ifieldinfo'
require 'girffi/iinterfaceinfo'
require 'girffi/ipropertyinfo'
require 'girffi/ivfuncinfo'
require 'girffi/isignalinfo'
require 'girffi/iobjectinfo'
require 'girffi/istructinfo'
require 'girffi/iunioninfo'
require 'girffi/ienuminfo'
require 'girffi/iflagsinfo'

module GirFFI
  class IRepository
    @@singleton = nil

    def self.default
      if @@singleton.nil?
	Helper::GType.init
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

    def info namespace, i
      ptr = Lib.g_irepository_get_info @gobj, namespace, i
      return info_from_pointer ptr
    end

    def find_by_name namespace, name
      ptr = Lib.g_irepository_find_by_name @gobj, namespace, name
      return info_from_pointer ptr
    end

    private_class_method :new

    def initialize(gobject)
      @gobj = gobject
    end

    private

    def info_from_pointer ptr
      return nil if ptr.null?
      type = Lib.g_base_info_get_type ptr
      case type
      when :object
	return IObjectInfo.new(ptr)
      when :function
	return IFunctionInfo.new(ptr)
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
	#raise "Returning base info object for #{type}"
	return IBaseInfo.new(ptr)
      end
    end
  end
end
