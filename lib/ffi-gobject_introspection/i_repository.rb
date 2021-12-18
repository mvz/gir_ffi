# frozen_string_literal: true

require "singleton"

require "ffi-gobject_introspection/lib"
require "ffi-gobject_introspection/strv"
require "ffi-gobject_introspection/g_error"

module GObjectIntrospection
  # The Gobject Introspection Repository. This class is the point of
  # access to the introspection typelibs.
  # This class wraps the GIRepository struct.
  class IRepository
    def initialize
      @pointer = Lib.g_irepository_get_default
    end

    def to_ptr
      @pointer
    end

    include Singleton

    def self.default
      instance
    end

    def self.prepend_search_path(path)
      Lib.g_irepository_prepend_search_path path
    end

    def self.type_tag_to_string(type)
      Lib.g_type_tag_to_string type
    end

    def require(namespace, version = nil, flags = 0)
      errpp = FFI::MemoryPointer.new(:pointer).write_pointer nil

      Lib.g_irepository_require self, namespace, version, flags, errpp

      errp = errpp.read_pointer
      raise GError.new(errp).message unless errp.null?
    end

    def n_infos(namespace)
      Lib.g_irepository_get_n_infos self, namespace
    end

    def info(namespace, index)
      wrap_info Lib.g_irepository_get_info(self, namespace, index)
    end

    # Utility method
    def infos(namespace)
      (0..(n_infos(namespace) - 1)).map do |idx|
        info namespace, idx
      end
    end

    def find_by_name(namespace, name)
      @name_cache ||= {}
      @name_cache[[namespace, name]] ||=
        wrap_info Lib.g_irepository_find_by_name(self, namespace, name)
    end

    def find_by_gtype(gtype)
      raise ArgumentError, "Type #{gtype} is not a valid type" if gtype == 0

      @gtype_cache ||= {}
      @gtype_cache[gtype] ||= wrap_info Lib.g_irepository_find_by_gtype(self, gtype)
    end

    def dependencies(namespace)
      strv_p = Lib.g_irepository_get_dependencies(self, namespace)
      strv = Strv.new strv_p
      strv.to_a
    end

    def shared_library(namespace)
      Lib.g_irepository_get_shared_library self, namespace
    end

    def version(namespace)
      Lib.g_irepository_get_version self, namespace
    end

    def self.wrap_ibaseinfo_pointer(ptr)
      return nil if ptr.null?

      type = Lib.g_base_info_get_type ptr
      klass = TYPEMAP[type]
      klass.wrap ptr
    end

    def inspect
      n_names = @name_cache ? @name_cache.length : 0
      n_types = @gtype_cache ? @gtype_cache.length : 0
      "#<%s 0x%x (cache toplevel: %d names, %d gtypes)>" % [
        self.class, self.object_id, n_names, n_types
      ]
    end

    private

    def wrap_info(ptr)
      self.class.wrap_ibaseinfo_pointer ptr
    end
  end
end
