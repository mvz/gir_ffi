module GIRepository
  class IRepository
    @@singleton = nil

    def self.default
      if @@singleton.nil?
	Helper::GType.init
	@@singleton = new(Lib::g_irepository_get_default)
      end
      @@singleton
    end

    def get_n_infos namespace
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

    def get_info namespace, i
      ptr = Lib.g_irepository_get_info @gobj, namespace, i
      case Lib.g_base_info_get_type ptr
      when :OBJECT
	return IObjectInfo.new(ptr)
      when :FUNCTION
	return IFunctionInfo.new(ptr)
      when :STRUCT
	return IStructInfo.new(ptr)
      else
	return IBaseInfo.new(ptr)
      end
    end

    private_class_method :new

    def initialize(gobject)
      @gobj = gobject
    end
  end
end
