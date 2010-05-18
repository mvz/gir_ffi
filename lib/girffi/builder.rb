require 'girffi'
require 'girffi/helper/arg'
require 'girffi/builder/function_definition'
require 'girffi/constructor_definition_builder'

module GirFFI
  # FIXME: No sign of state here yet. Perhaps this should be a module.
  class Builder
    def build_class namespace, classname, box=nil
      gir = GirFFI::IRepository.default
      gir.require namespace, nil

      info = gir.find_by_name namespace, classname
      parent = info.parent
      if parent
	superclass = build_class parent.namespace, parent.name, box
      end

      namespacem = setup_module namespace, box
      klass = get_or_define_class namespacem, classname, superclass

      lb = get_or_define_module namespacem, :Lib

      # TODO: Don't extend etc. if already done.
      lb.extend FFI::Library
      libs = gir.shared_library(namespace).split(/,/)
      lb.ffi_lib(*libs)

      optionally_define_constant lb, :CALLBACKS, []

      unless klass.method_defined? :method_missing
	klass.class_eval method_missing_definition lb, namespace, classname
      end

      unless parent
	klass.class_exec do
	  def to_ptr
	    @gobj
	  end
	end
      end

      unless info.abstract?
	ctor = info.find_method 'new'
	if ctor.constructor?
	  define_ffi_types lb, ctor
	  attach_ffi_function lb, ctor
	  klass.class_eval constructor_definition ctor, lb
	end
      end
      klass
    end

    def build_module namespace, box=nil
      modul = setup_module namespace, box

      unless modul.respond_to? :method_missing
	modul.class_eval method_missing_definition "Lib", namespace
      end

      gir = GirFFI::IRepository.default
      gir.require namespace, nil

      lb = get_or_define_module modul, :Lib

      # TODO: Don't extend etc. if already done.
      lb.extend FFI::Library
      libs = gir.shared_library(namespace).split(/,/)
      lb.ffi_lib(*libs)

      optionally_define_constant lb, :CALLBACKS, []
      modul
    end

    # FIXME: Methods that follow should be private
    def function_definition info, libmodule
      fdbuilder = FunctionDefinition.new info, libmodule
      fdbuilder.generate
    end

    def constructor_definition info, libmodule
      fdbuilder = ConstructorDefinitionBuilder.new info, libmodule
      fdbuilder.generate
    end

    def function_introspection_data namespace, function
      gir = GirFFI::IRepository.default
      gir.require namespace.to_s, nil
      return gir.find_by_name namespace, function.to_s
    end

    def method_introspection_data namespace, object, method
      gir = GirFFI::IRepository.default
      gir.require namespace.to_s, nil
      objectinfo = gir.find_by_name namespace, object.to_s
      return objectinfo.find_method method
    end

    def attach_ffi_function modul, info
      sym = info.symbol
      argtypes = ffi_function_argument_types info
      rt = ffi_function_return_type info

      modul.attach_function sym, argtypes, rt
    end

    def ffi_function_argument_types info
      types = info.args.map do |a|
	iarginfo_to_ffitype a
      end
      if info.type == :function
	types.unshift :pointer if info.method?
      end
      types
    end

    def ffi_function_return_type info
      itypeinfo_to_ffitype info.return_type
    end

    def define_ffi_types modul, info
      info.args.each do |a|
	type = iarginfo_to_ffitype a
	# FIXME: Rescue is ugly here.
	ft = modul.find_type type rescue nil
	next unless ft.nil?
	define_single_ffi_type modul, a.type
      end
    end

    private

    def itypeinfo_to_ffitype info
      if info.pointer?
	return :string if info.tag == :utf8
	return :pointer
      end
      if info.tag == :interface
	return info.interface.name.to_sym
      end
      return IRepository.type_tag_to_string(info.tag).to_sym
    end

    def iarginfo_to_ffitype info
      return :pointer if info.direction == :inout
      return itypeinfo_to_ffitype info.type
    end

    def define_single_ffi_type modul, typeinfo
      typeinfo.tag == :interface or raise NotImplementedError

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

    def get_or_define_module parent, name
      unless parent.const_defined? name
	parent.const_set name, Module.new
      end
      parent.const_get name
    end

    def get_or_define_class namespace, name, parent
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

    def optionally_define_constant parent, name, value
      unless parent.const_defined? name
	parent.const_set name, value
      end
    end

    def setup_module namespace, box=nil
      if box.nil?
	boxm = ::Object
      else
	boxm = get_or_define_module ::Object, box.to_s
      end
      return get_or_define_module boxm, namespace.to_s
    end

    def method_missing_definition lib, namespace, classname=nil
      if classname.nil?
	slf = "self."
	fn = "function_introspection_data"
	args = ["\"#{namespace}\""]
      else
	slf = ""
	fn = "method_introspection_data"
	args = ["\"#{namespace}\"", "\"#{classname}\""]
      end

      return <<-CODE
	def #{slf}method_missing method, *arguments, &block
	  @@builder ||= GirFFI::Builder.new

	  go = @@builder.#{fn} #{args.join ', '}, method.to_s

	  return super if go.nil?
	  return super if go.type != :function

	  @@builder.define_ffi_types #{lib}, go
	  @@builder.attach_ffi_function #{lib}, go

	  (class << self; self; end).class_eval @@builder.function_definition(go, #{lib})

	  if block.nil?
	    self.send method, *arguments
	  else
	    self.send method, *arguments, &block
	  end
	end
      CODE
    end
  end
end
