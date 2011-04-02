require 'gir_ffi/arg_helper'
require 'gir_ffi/builder/function'
require 'gir_ffi/class_base'
require 'gir_ffi/builder/class'
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
      Builder::Class.new(info).generate
    end

    def self.build_module namespace, version=nil
      Builder::Module.new(namespace, version).generate
    end

    def self.attach_ffi_function lib, info
      sym = info.symbol
      argtypes = ffi_function_argument_types info
      rt = ffi_function_return_type info

      lib.attach_function sym, argtypes, rt
    end

    def self.ffi_function_argument_types info
      types = info.args.map do |arg|
	tp = iarginfo_to_ffitype arg
	tp == :string ? :pointer : tp
      end
      if info.type == :function
	types.unshift :pointer if info.method?
	types << :pointer if info.throws?
      end
      types
    end

    def self.ffi_function_return_type info
      itypeinfo_to_ffitype info.return_type
    end

    def self.itypeinfo_to_ffitype info
      tag = info.tag

      if info.pointer?
	return :string if tag == :utf8
	return :pointer
      end

      case tag
      when :interface
        return build_class info.interface
      else
        return TAG_TYPE_MAP[tag]
      end
    end

    def self.iarginfo_to_ffitype info
      return :pointer if info.direction == :inout
      return :pointer if info.direction == :out
      return itypeinfo_to_ffitype info.type
    end
  end
end
