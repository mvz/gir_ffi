require 'girffi'
require 'girffi/class_base'
require 'girffi/arg_helper'
require 'girffi/function_definition_builder'
require 'girffi/constructor_definition_builder'

module GirFFI
  # Builds modules and classes based on information found in the
  # introspection repository. Call its build_module and build_class methods
  # to create the modules and classes used in your program.
  module Builder
    def self.build_class namespace, classname, box=nil
      gir = IRepository.default
      gir.require namespace, nil

      info = gir.find_by_name namespace, classname
      raise "Class #{classname} not found in namespace #{namespace}" if info.nil?
      parent = info.type == :object ? info.parent : nil
      if parent
	superclass = build_class parent.namespace, parent.name, box
      end

      namespacem = setup_module namespace, box
      klass = get_or_define_class namespacem, classname, superclass

      lb = setup_lib_for_ffi namespace, namespacem

      unless klass.instance_methods(false).include? "method_missing"
	klass.class_eval method_missing_definition :instance, lb, namespace, classname
	klass.class_eval method_missing_definition :class, lb, namespace, classname

	unless parent
	  klass.class_exec do
	    include GirFFI::ClassBase
	    class << self; alias :_real_new :new; end
	  end
	end

	unless info.type == :object and info.abstract?
	  ctor = info.find_method 'new'
	  if not ctor.nil? and ctor.constructor?
	    define_ffi_types lb, ctor
	    attach_ffi_function lb, ctor
	    (class << klass; self; end).class_eval function_definition ctor, lb
	  end
	end
      end
      klass
    end

    def self.build_module namespace, box=nil
      IRepository.default.require namespace, nil
      modul = setup_module namespace, box
      lb = setup_lib_for_ffi namespace, modul
      unless modul.respond_to? :method_missing
	modul.class_eval method_missing_definition :module, lb, namespace
	modul.class_eval const_missing_definition namespace, box
      end
      modul
    end

    # FIXME: Methods that follow should be private
    def self.function_definition info, libmodule
      if info.constructor?
	fdbuilder = ConstructorDefinitionBuilder.new info, libmodule
      else
	fdbuilder = FunctionDefinitionBuilder.new info, libmodule
      end
      fdbuilder.generate
    end

    def self.function_introspection_data namespace, function
      gir = GirFFI::IRepository.default
      gir.require namespace.to_s, nil
      return gir.find_by_name namespace, function.to_s
    end

    def self.method_introspection_data namespace, object, method
      gir = GirFFI::IRepository.default
      gir.require namespace.to_s, nil
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

    def self.define_ffi_types modul, info
      info.args.each do |arg|
	type = iarginfo_to_ffitype arg
	# FIXME: Rescue is ugly here.
	ft = modul.find_type type rescue nil
	next unless ft.nil?
	define_single_ffi_type modul, arg.type
      end
    end

    private

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

    def self.define_single_ffi_type modul, typeinfo
      typeinfo.tag == :interface or raise NotImplementedError, "Don't know how to handle #{typeinfo.tag}"

      interface = typeinfo.interface
      sym = interface.name.to_sym

      case interface.type
      when :callback
	args = ffi_function_argument_types interface
	ret = ffi_function_return_type interface
	modul.callback sym, args, ret
      when :enum, :flags
	vals = interface.values.map {|v| [v.name.to_sym, v.value]}.flatten
	modul.enum sym, vals
      else
	raise NotImplementedError
      end
    end

    def self.get_or_define_module parent, name
      unless parent.const_defined? name
	parent.const_set name, Module.new
      end
      parent.const_get name
    end

    def self.get_or_define_class namespace, name, parent
      unless namespace.const_defined? name
	if parent.nil?
	  klass = Class.new
	else
	  klass = Class.new parent
	end
	namespace.const_set name, klass
      end
      namespace.const_get name
    end

    def self.optionally_define_constant parent, name, value
      unless parent.const_defined? name
	parent.const_set name, value
      end
    end

    def self.setup_module namespace, box=nil
      if box.nil?
	boxm = ::Object
      else
	boxm = get_or_define_module ::Object, box.to_s
      end
      return get_or_define_module boxm, namespace.to_s
    end

    def self.method_missing_definition type, lib, namespace, classname=nil
      case type
      when :module
	raise ArgumentError unless classname.nil?
	slf = "self."
	fn = "function_introspection_data"
	args = ["\"#{namespace}\""]
      when :instance
	slf = ""
	fn = "method_introspection_data"
	args = ["\"#{namespace}\"", "\"#{classname}\""]
      when :class
	slf = "self."
	fn = "method_introspection_data"
	args = ["\"#{namespace}\"", "\"#{classname}\""]
      end

      return <<-CODE
	def #{slf}method_missing method, *arguments, &block
	  go = GirFFI::Builder.#{fn} #{args.join ', '}, method.to_s

	  return super if go.nil?
	  return super if go.type != :function

	  GirFFI::Builder.define_ffi_types #{lib}, go
	  GirFFI::Builder.attach_ffi_function #{lib}, go

	  (class << self; self; end).class_eval GirFFI::Builder.function_definition(go, #{lib})

	  if block.nil?
	    self.send method, *arguments
	  else
	    self.send method, *arguments, &block
	  end
	end
      CODE
    end

    def self.const_missing_definition namespace, box=nil
      box = box.nil? ? "nil" : "\"#{box}\""
      return <<-CODE
	def self.const_missing classname
	  info = IRepository.default.find_by_name "#{namespace}", classname.to_s
	  return super if info.nil?
	  return GirFFI::Builder.build_class "#{namespace}", classname.to_s, #{box}
	end
      CODE
    end
    def self.setup_lib_for_ffi namespace, modul
      lb = get_or_define_module modul, :Lib

      unless (class << lb; self.include? FFI::Library; end)
	lb.extend FFI::Library
	libs = IRepository.default.shared_library(namespace).split(/,/)
	lb.ffi_lib(*libs)
      end

      optionally_define_constant lb, :CALLBACKS, []
      return lb
    end
  end
end
