require 'gir_ffi/builder_helper'
module GirFFI
  # Builds a class based on information found in the introspection
  # repository.
  class Builder::Class
    include BuilderHelper
    def initialize namespace, classname
      @namespace = namespace
      @classname = classname
    end

    def generate
      build_class
    end

    def setup_method method
      klass = build_class
      meta = (class << klass; self; end)

      go = method_introspection_data method
      return attach_and_define_method method, go, meta
    end

    def setup_instance_method method
      go = instance_method_introspection_data method
      result = attach_and_define_method method, go, build_class

      unless result
        if parent
          return superclass.gir_ffi_builder.setup_instance_method method
        else
          return false
        end
      end

      true
    end

    def find_signal signal_name
      signal_definers.each do |inf|
        inf.signals.each do |sig|
          return sig if sig.name == signal_name
        end
      end
      if parent
        return superclass.gir_ffi_builder.find_signal signal_name
      end
    end

    private

    def build_class
      unless defined? @klass
        case info.type
        when :object, :struct, :interface
          instantiate_struct_class
        when :union
          instantiate_union_class
        when :enum, :flags
          instantiate_enum_class
        when :callback
          instantiate_callback_class
        else
          raise NotImplementedError, "Cannot build classes of type #{info.type}"
        end
      end
      @klass
    end

    def info
      unless defined? @info
        @info = gir.find_by_name @namespace, @classname
        raise "Class #{@classname} not found in namespace #{@namespace}" if @info.nil?
      end
      @info
    end

    def parent
      unless defined? @parent
        if info.type == :object
	  pr = info.parent
	  if pr.nil? or (pr.name == @classname and pr.namespace == @namespace)
	    @parent = nil
	  else
	    @parent = pr
	  end
	else
	  @parent = nil
	end
      end
      @parent
    end

    def superclass
      unless defined? @superclass
        if parent
          @superclass = Builder.build_class parent.namespace, parent.name
        else
          @superclass = GirFFI::ClassBase
        end
      end
      @superclass
    end

    def namespace_module
      @namespace_module ||= Builder.build_module @namespace
    end

    def lib
      @lib ||= namespace_module.const_get :Lib
    end

    def instantiate_struct_class
      @klass = get_or_define_class namespace_module, @classname, superclass
      @structklass = get_or_define_class @klass, :Struct, FFI::Struct
      setup_class unless already_set_up
    end

    def instantiate_union_class
      @klass = get_or_define_class namespace_module, @classname, superclass
      @structklass = get_or_define_class @klass, :Struct, FFI::Union
      setup_class unless already_set_up
    end

    def instantiate_enum_class
      @klass = optionally_define_constant namespace_module, @classname do
        vals = info.values.map {|vinfo| [vinfo.name.to_sym, vinfo.value]}.flatten
        lib.enum(@classname.to_sym, vals)
      end
    end

    def instantiate_callback_class
      @klass = optionally_define_constant namespace_module, @classname do
	args = Builder.ffi_function_argument_types info
	ret = Builder.ffi_function_return_type info
	lib.callback @classname.to_sym, args, ret
      end
    end

    def setup_class
      setup_layout
      setup_constants
      stub_methods
      setup_gtype_getter

      setup_vfunc_invokers if info.type == :object
      provide_struct_constructor if info.type == :struct
    end

    def setup_layout
      spec = layout_specification
      @structklass.class_eval { layout(*spec) }
    end

    def layout_specification
      fields = if info.type == :interface
                 []
               else
                 info.fields
               end

      if fields.empty?
        if parent
          return [:parent, superclass.const_get(:Struct), 0]
        else
          return [:dummy, :char, 0]
        end
      end

      fields.map do |finfo|
        [ finfo.name.to_sym,
          itypeinfo_to_ffitype_for_struct(finfo.type),
          finfo.offset ]
      end.flatten
    end

    def itypeinfo_to_ffitype_for_struct typeinfo
      ffitype = Builder.itypeinfo_to_ffitype typeinfo
      if ffitype.kind_of?(Class) and const_defined_for ffitype, :Struct
        ffitype = ffitype.const_get :Struct
      end
      if ffitype == :bool
        ffitype = :int
      end
      ffitype
    end

    def stub_methods
      info.methods.each do |minfo|
        @klass.class_eval method_stub(minfo.name, minfo.method?)
      end
    end

    def method_stub symbol, is_instance_method
      "
        def #{is_instance_method ? '' : 'self.'}#{symbol} *args, &block
          setup_and_call :#{symbol}, *args, &block
        end
      "
    end

    def setup_gtype_getter
      getter = info.type_init
      return if getter.nil? or getter == "intern"
      lib.attach_function getter.to_sym, [], :size_t
      @klass.class_eval "
        def self.get_gtype
          ::#{lib}.#{getter}
        end
      "
    end

    def setup_vfunc_invokers
      info.vfuncs.each do |vfinfo|
        invoker = vfinfo.invoker
        next if invoker.nil?
        next if invoker.name == vfinfo.name

        @klass.class_eval "
          def #{vfinfo.name} *args, &block
            #{invoker.name}(*args, &block)
          end
        "
      end
    end

    def provide_struct_constructor
      return if info.find_method 'new'

      (class << @klass; self; end).class_eval {
        alias_method :new, :allocate
      }
    end

    def setup_constants
      @klass.const_set :GIR_INFO, info
      @klass.const_set :GIR_FFI_BUILDER, self
    end

    def already_set_up
      const_defined_for @klass, :GIR_FFI_BUILDER
    end

    def method_introspection_data method
      info.find_method method
    end

    def instance_method_introspection_data method
      data = method_introspection_data method
      return !data.nil? && data.method? ? data : nil
    end

    def function_definition go
      Builder::Function.new(go, lib).generate
    end

    def attach_and_define_method method, go, modul
      return false if go.nil?
      Builder.attach_ffi_function lib, go
      modul.class_eval { remove_method method }
      modul.class_eval function_definition(go)
      true
    end

    def gir
      unless defined? @gir
        @gir = IRepository.default
        @gir.require @namespace, nil
      end
      @gir
    end

    def get_or_define_class namespace, name, parent
      optionally_define_constant(namespace, name) {
        Class.new parent
      }
    end

    def signal_definers
      [info] + (info.type == :object ? info.interfaces : [])
    end
  end
end
