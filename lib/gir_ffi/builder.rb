require 'gir_ffi/arg_helper'
require 'gir_ffi/function_definition_builder'
require 'gir_ffi/class_base'
require 'gir_ffi/class_builder'
require 'gir_ffi/module_builder'
require 'gir_ffi/builder_helper'

module GirFFI
  # Builds modules and classes based on information found in the
  # introspection repository. Call its build_module and build_class methods
  # to create the modules and classes used in your program.
  module Builder
    extend BuilderHelper
    def self.build_class namespace, classname
      ClassBuilder.new(namespace, classname).generate
    end

    def self.build_module namespace
      ModuleBuilder.new(namespace).generate
    end

    def self.attach_ffi_function lib, info
      sym = info.symbol
      argtypes = ffi_function_argument_types info
      rt = ffi_function_return_type info

      lib.attach_function sym, argtypes, rt
    end

    # All methods below will be made private at the end.

    def self.ffi_function_argument_types info
      types = info.args.map do |a|
	iarginfo_to_ffitype a
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
	interface = info.interface
	case interface.type
	when :object, :struct, :flags, :enum
	  return build_class interface.namespace, interface.name
	when :callback
	  return build_callback interface
	else
	  raise NotImplementedError
	end
      when :boolean
	return :bool
      when :GType
	return :int32
      else
	return tag
      end
    end

    def self.iarginfo_to_ffitype info
      return :pointer if info.direction == :inout
      return :pointer if info.direction == :out
      return itypeinfo_to_ffitype info.type
    end

    def self.build_callback interface
      modul = build_module interface.namespace
      lib = modul.const_get(:Lib)

      sym = interface.name.to_sym

      optionally_define_constant modul, sym do
	args = ffi_function_argument_types interface
	ret = ffi_function_return_type interface
	lib.callback sym, args, ret
      end
    end

    # Set up method access.
    (self.public_methods - Module.public_methods).each do |m|
      private_class_method m.to_sym
    end
    public_class_method :build_module, :build_class
    public_class_method :itypeinfo_to_ffitype
    public_class_method :attach_ffi_function
  end
end
