require 'gir_ffi/arg_helper'
require 'gir_ffi/builder/function'
require 'gir_ffi/class_base'
require 'gir_ffi/builder/type'
require 'gir_ffi/builder/module'
require 'gir_ffi/builder_helper'

module GirFFI
  # Builds modules and classes based on information found in the
  # introspection repository. Call its build_module and build_class methods
  # to create the modules and classes used in your program.
  module Builder
    extend BuilderHelper

    TAG_TYPE_MAP = {
      :GType => :size_t,
      :gboolean => :bool,
      :gunichar => :uint32,
      :gint8 => :int8,
      :guint8 => :uint8,
      :gint16 => :int16,
      :guint16 => :uint16,
      :gint32 => :int32,
      :guint32 => :uint32,
      :gint64 => :int64,
      :guint64 => :uint64,
      :gfloat => :float,
      :gdouble => :double,
      :void => :void
    }

    def self.build_class info
      Builder::Type.build(info)
    end

    def self.build_module namespace, version=nil
      Builder::Module.new(namespace, version).generate
    end

    def self.build_module_non_recursive namespace, version=nil
      Builder::Module.new(namespace, version).build_module_non_recursive
    end

    def self.attach_ffi_function lib, info
      sym = info.symbol
      argtypes = ffi_function_argument_types info
      rt = ffi_function_return_type info

      lib.attach_function sym, argtypes, rt
    end

    def self.ffi_function_argument_types info
      types = info.args.map { |arg| iarginfo_to_ffitype arg }

      if info.info_type == :function
	types.unshift :pointer if info.method?
	types << :pointer if info.throws?
      end

      types
    end

    def self.ffi_function_return_type info
      rt = info.return_type
      return :string if rt.tag == :utf8
      itypeinfo_to_ffitype rt
    end

    def self.itypeinfo_to_ffitype info
      return :pointer if info.pointer?

      tag = info.tag
      if tag == :interface
        return build_class info.interface
      else
        return TAG_TYPE_MAP[tag] || tag
      end
    end

    def self.iarginfo_to_ffitype info
      return :pointer if info.direction != :in
      return itypeinfo_to_ffitype info.argument_type
    end
  end
end
