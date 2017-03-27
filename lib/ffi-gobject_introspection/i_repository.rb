# frozen_string_literal: true

require 'singleton'

require 'ffi-gobject_introspection/lib'
require 'ffi-gobject_introspection/strv'
require 'ffi-gobject_introspection/g_error'

module GObjectIntrospection
  # The Gobject Introspection Repository. This class is the point of
  # access to the introspection typelibs.
  # This class wraps the GIRepository struct.
  class IRepository
    def initialize
      @gobj = Lib.g_irepository_get_default
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

      Lib.g_irepository_require @gobj, namespace, version, flags, errpp

      errp = errpp.read_pointer
      raise GError.new(errp).message unless errp.null?
    end

    def n_infos(namespace)
      Lib.g_irepository_get_n_infos @gobj, namespace
    end

    def info(namespace, index)
      wrap_info Lib.g_irepository_get_info(@gobj, namespace, index)
    end

    # Utility method
    def infos(namespace)
      (0..(n_infos(namespace) - 1)).map do |idx|
        info namespace, idx
      end
    end

    def find_by_name(namespace, name)
      wrap_info Lib.g_irepository_find_by_name(@gobj, namespace, name)
    end

    def find_by_gtype(gtype)
      raise ArgumentError, "Type #{gtype} is not a valid type" if gtype.zero?
      wrap_info Lib.g_irepository_find_by_gtype(@gobj, gtype)
    end

    def dependencies(namespace)
      strv_p = Lib.g_irepository_get_dependencies(@gobj, namespace)
      strv = Strv.new strv_p
      strv.to_a
    end

    def shared_library(namespace)
      Lib.g_irepository_get_shared_library @gobj, namespace
    end

    def version(namespace)
      Lib.g_irepository_get_version @gobj, namespace
    end

    def self.wrap_ibaseinfo_pointer(ptr)
      return nil if ptr.null?
      type = Lib.g_base_info_get_type ptr
      klass = TYPEMAP[type]
      klass.wrap ptr
    end

    private

    def wrap_info(ptr)
      self.class.wrap_ibaseinfo_pointer ptr
    end
  end
end
