require 'girffi'
require 'girffi/class_base'
require 'girffi/arg_helper'
require 'girffi/function_definition_builder'
require 'girffi/constructor_definition_builder'
require 'girffi/method_missing_definition_builder'
require 'girffi/class_builder'
require 'girffi/module_builder'
require 'girffi/builder_helper'

module GirFFI
  # Builds modules and classes based on information found in the
  # introspection repository. Call its build_module and build_class methods
  # to create the modules and classes used in your program.
  module Builder
    def self.build_class namespace, classname, box=nil
      ClassBuilder.new(namespace, classname, box).generate
    end

    def self.build_module namespace, box=nil
      ModuleBuilder.new(namespace, box).generate
    end

    # TODO: Make better interface
    def self.setup_method namespace, classname, lib, modul, klass, method
      go = method_introspection_data namespace, classname, method.to_s

      setup_function_or_method klass, modul, lib, go
    end

    # TODO: Make better interface
    def self.setup_function namespace, lib, modul, method
      go = function_introspection_data namespace, method.to_s

      setup_function_or_method modul, modul, lib, go
    end

    # All methods below will be made private at the end.
 
    def self.function_definition info, libmodule
      if info.constructor?
	fdbuilder = ConstructorDefinitionBuilder.new info, libmodule
      else
	fdbuilder = FunctionDefinitionBuilder.new info, libmodule
      end
      fdbuilder.generate
    end

    def self.function_introspection_data namespace, function
      gir = IRepository.default
      return gir.find_by_name namespace, function.to_s
    end

    def self.method_introspection_data namespace, object, method
      gir = IRepository.default
      objectinfo = gir.find_by_name namespace, object.to_s
      return objectinfo.find_method method
    end

    def self.attach_ffi_function modul, info
      sym = info.symbol
      argtypes = ffi_function_argument_types info
      rt = ffi_function_return_type info

      modul.attach_function sym, argtypes, rt
    end

    def self.ffi_function_argument_types info
      types = info.args.map do |a|
	iarginfo_to_ffitype a
      end
      if info.type == :function
	types.unshift :pointer if info.method?
      end
      types
    end

    def self.ffi_function_return_type info
      itypeinfo_to_ffitype info.return_type
    end

    def self.define_ffi_types modul, lib, info
      info.args.each do |arg|
	type = iarginfo_to_ffitype arg
	# FIXME: Rescue is ugly here.
	ft = lib.find_type type rescue nil
	next unless ft.nil?
	define_single_ffi_type modul, lib, arg.type
      end
    end

    def self.itypeinfo_to_ffitype info
      if info.pointer?
	return :string if info.tag == :utf8
	return :pointer
      end
      case info.tag
      when :interface
	return info.interface.name.to_sym
      when :boolean
	return :bool
      else
	return info.tag
      end
    end

    def self.iarginfo_to_ffitype info
      return :pointer if info.direction == :inout
      return itypeinfo_to_ffitype info.type
    end

    def self.define_single_ffi_type modul, lib, typeinfo
      typeinfo.tag == :interface or raise NotImplementedError, "Don't know how to handle #{typeinfo.tag}"

      interface = typeinfo.interface
      sym = interface.name.to_sym

      case interface.type
      when :callback
	args = ffi_function_argument_types interface
	ret = ffi_function_return_type interface
	lib.callback sym, args, ret
      when :enum, :flags
	vals = interface.values.map {|v| [v.name.to_sym, v.value]}.flatten
	modul.const_set sym, lib.enum(sym, vals)
      else
	raise NotImplementedError
      end
    end

    def self.setup_function_or_method klass, modul, lib, go
      return false if go.nil?
      return false if go.type != :function

      define_ffi_types modul, lib, go
      attach_ffi_function lib, go

      (class << klass; self; end).class_eval function_definition(go, lib)
      true
    end

    # Set up method access.
    (self.public_methods - Module.public_methods).each do |m|
      private_class_method m.to_sym
    end
    public_class_method :build_module, :build_class, :setup_method, :setup_function, :setup_function_or_method
  end
end
