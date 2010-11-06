require 'gir_ffi/arg_helper'
require 'gir_ffi/function_definition_builder'
require 'gir_ffi/constructor_definition_builder'
require 'gir_ffi/method_missing_definition_builder'
require 'gir_ffi/base'
require 'gir_ffi/class_builder'
require 'gir_ffi/module_builder'
require 'gir_ffi/builder_helper'

module GirFFI
  # Builds modules and classes based on information found in the
  # introspection repository. Call its build_module and build_class methods
  # to create the modules and classes used in your program.
  module Builder
    def self.build_class namespace, classname
      ClassBuilder.new(namespace, classname).generate
    end

    def self.build_module namespace
      ModuleBuilder.new(namespace).generate
    end

    def self.setup_method namespace, classname, method
      go = method_introspection_data namespace, classname, method.to_s

      return false if go.nil?
      return false if go.type != :function

      klass = build_class namespace, classname
      modul = build_module namespace
      lib = modul.const_get(:Lib)

      attach_ffi_function modul, lib, go

      meta = (class << klass; self; end)
      meta.class_eval function_definition(go, lib)

      true
    end

    def self.setup_function namespace, method
      go = function_introspection_data namespace, method.to_s

      return false if go.nil?
      return false if go.type != :function

      modul = build_module namespace
      lib = modul.const_get(:Lib)

      attach_ffi_function modul, lib, go

      meta = (class << modul; self; end)
      meta.class_eval function_definition(go, lib)

      true
    end

    def self.setup_instance_method namespace, classname, method
      go = method_introspection_data namespace, classname, method.to_s

      return false if go.nil?
      return false if go.type != :function

      klass = build_class namespace, classname
      modul = build_module namespace
      lib = modul.const_get(:Lib)

      attach_ffi_function modul, lib, go

      klass.class_eval function_definition(go, lib)

      true
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

    def self.attach_ffi_function modul, lib, info
      sym = info.symbol
      argtypes = ffi_function_argument_types modul, lib, info
      rt = ffi_function_return_type modul, lib, info

      lib.attach_function sym, argtypes, rt
    end

    def self.ffi_function_argument_types modul, lib, info
      types = info.args.map do |a|
	iarginfo_to_ffitype modul, lib, a
      end
      if info.type == :function
	types.unshift :pointer if info.method?
      end
      types
    end

    def self.ffi_function_return_type modul, lib, info
      itypeinfo_to_ffitype modul, lib, info.return_type
    end

    def self.itypeinfo_to_ffitype modul, lib, info
      modul = nil
      if info.pointer?
	return :string if info.tag == :utf8
	return :pointer
      end
      case info.tag
      when :interface
	interface = info.interface
	case interface.type
	when :object, :struct, :flags, :enum
	  return build_class interface.namespace, interface.name
	when :callback
	  return build_callback modul, lib, interface
	else
	  raise NotImplementedError
	end
      when :boolean
	return :bool
      when :GType
	return :int32
      else
	return info.tag
      end
    end

    def self.iarginfo_to_ffitype modul, lib, info
      return :pointer if info.direction == :inout
      return itypeinfo_to_ffitype modul, lib, info.type
    end

    def self.build_callback modul, lib, interface
      sym = interface.name.to_sym

      # FIXME: Rescue is ugly here.
      ft = lib.find_type sym rescue nil
      if ft.nil?
	args = ffi_function_argument_types modul, lib, interface
	ret = ffi_function_return_type modul, lib, interface
	lib.callback sym, args, ret
      end
      sym
    end

    # Set up method access.
    (self.public_methods - Module.public_methods).each do |m|
      private_class_method m.to_sym
    end
    public_class_method :build_module, :build_class
    public_class_method :setup_method, :setup_function, :setup_instance_method
    public_class_method :itypeinfo_to_ffitype
  end
end
