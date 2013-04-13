require 'gir_ffi/builder/type'
require 'gir_ffi/builder/type/unintrospectable'
require 'gir_ffi/builder/module'
require 'gir_ffi/builder_helper'

module GirFFI
  # Builds modules and classes based on information found in the
  # introspection repository. Call its build_module and build_class methods
  # to create the modules and classes used in your program.
  module Builder
    extend BuilderHelper

    def self.build_class info
      Builder::Type.build(info)
    end

    def self.build_by_gtype gtype
      info = GObjectIntrospection::IRepository.default.find_by_gtype gtype
      if info.nil?
        Builder::Type::Unintrospectable.new(gtype).build_class
      else
        build_class info
      end
    end

    def self.build_module namespace, version=nil
      Builder::Module.new(namespace, version).generate
    end

    def self.build_module_non_recursive namespace, version=nil
      Builder::Module.new(namespace, version).build_module_non_recursive
    end

    def self.build_callback callable_info, &block
      rettype = ffi_callback_return_type callable_info
      argtypes = ffi_callback_argument_types callable_info

      FFI::Function.new rettype, argtypes, &block
    end

    # TODO: Move elsewhere, perhaps to Builder::Function.
    def self.attach_ffi_function lib, info
      sym = info.symbol
      return if lib.method_defined? sym
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

    def self.ffi_callback_argument_types info
      types = info.args.map do |arg|
        itypeinfo_to_callback_ffitype arg.argument_type
      end
      types.unshift(:pointer).push(:pointer)
    end

    def self.ffi_callback_return_type info
      ffi_function_return_type info
    end

    def self.ffi_function_return_type info
      itypeinfo_to_ffitype info.return_type
    end

    def self.itypeinfo_to_callback_ffitype info
      tag = info.tag

      return :string if tag == :utf8
      return :pointer if info.pointer?

      if tag == :interface
        case info.interface.info_type
        when :enum, :flags
          :int32
        else
          :pointer
        end
      else
        return TypeMap.map_basic_type tag
      end
    end

    def self.itypeinfo_to_ffitype info
      return :pointer if info.pointer?

      tag = info.tag
      if tag == :interface
        return build_class info.interface
      else
        return TypeMap.map_basic_type tag
      end
    end

    def self.iarginfo_to_ffitype info
      return :pointer if info.direction != :in
      return itypeinfo_to_ffitype info.argument_type
    end
  end
end
