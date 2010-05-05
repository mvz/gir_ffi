require 'girffi/helper/arg'
require 'girffi/builder/function_definition'

module GirFFI
  # FIXME: No sign of state here yet. Perhaps this should be a module.
  class Builder
    def build_object namespace, classname, box=nil
      namespacem = setup_module namespace, box
      klass = get_or_define_class namespacem, classname.to_s

      klass.class_eval <<-CODE
	def method_missing method, *arguments
	end
      CODE

      gir = GirFFI::IRepository.default
      gir.require namespace, nil

      lb = get_or_define_module namespacem, :Lib
      lb.extend FFI::Library
      libs = gir.shared_library(namespace).split(/,/)
      lb.ffi_lib(*libs)
    end

    def build_module namespace, box=nil
      modul = setup_module namespace, box

      modul.class_eval <<-CODE
	def self.method_missing method, *arguments
	  @@builder ||= GirFFI::Builder.new

	  go = @@builder.function_introspection_data "#{namespace}", method.to_s

	  return super if go.nil?
	  return super if go.type != :function

	  @@builder.attach_ffi_function Lib, go

	  (class << self; self; end).class_eval @@builder.function_definition(go)

	  self.send method, *arguments
	end
      CODE

      gir = GirFFI::IRepository.default
      gir.require namespace, nil

      lb = get_or_define_module modul, :Lib
      lb.extend FFI::Library
      libs = gir.shared_library(namespace).split(/,/)
      lb.ffi_lib(*libs)
    end

    # FIXME: Methods that follow should be private
    def function_definition info
      fdbuilder = FunctionDefinition.new info
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
      tps = info.args.map {|a| iarginfo_to_ffitype a}
      if info.method?
	tps.unshift :pointer
      end
      tps
    end

    def ffi_function_return_type info
      itypeinfo_to_ffitype info.return_type
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

    def get_or_define_module parent, name
      unless parent.const_defined? name
	parent.const_set name, Module.new
      end
      parent.const_get name
    end

    def get_or_define_class parent, name
      unless parent.const_defined? name
	parent.const_set name, Class.new
      end
      parent.const_get name
    end

    def setup_module namespace, box=nil
      if box.nil?
	boxm = ::Object
      else
	boxm = get_or_define_module ::Object, box.to_s
      end
      return get_or_define_module boxm, namespace.to_s
    end
  end
end
