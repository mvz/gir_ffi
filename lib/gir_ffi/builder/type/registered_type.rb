require 'gir_ffi/builder/type/base'
require 'gir_ffi/class_base'

module GirFFI
  module Builder
    module Type

      # Base class for type builders building types specified by subtypes
      # of IRegisteredTypeInfo. These are types whose C representation is
      # complex, i.e., a struct or a union.
      class RegisteredType < Base
        def setup_method method
          klass = build_class
          meta = (class << klass; self; end)

          go = method_introspection_data method
          attach_and_define_method method, go, meta
        end

        def setup_instance_method method
          go = instance_method_introspection_data method
          attach_and_define_method method, go, build_class
        end

        private

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

        def setup_class
          setup_layout
          setup_constants
          stub_methods
          setup_gtype_getter
        end

        def setup_layout
          spec = layout_specification
          @structklass.class_eval { layout(*spec) }
        end

        def layout_specification
          fields = info.fields

          if fields.empty?
            if parent
              return [:parent, superclass.const_get(:Struct), 0]
            else
              return [:dummy, :char, 0]
            end
          end

          fields.map do |finfo|
            [ finfo.name.to_sym,
              itypeinfo_to_ffitype_for_struct(finfo.field_type),
              finfo.offset ]
          end.flatten
        end

        # FIXME: Move this into a class with the other type knowledge.
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

        def setup_constants
          @klass.const_set :GIR_INFO, info
          @klass.const_set :GIR_FFI_BUILDER, self
        end

        def already_set_up
          const_defined_for @klass, :GIR_FFI_BUILDER
        end

        def stub_methods
          info.get_methods.each do |minfo|
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

        # TODO: Rename the created method, or use a constant.
        def setup_gtype_getter
          gtype = info.g_type
          return if gtype.nil?
          @klass.instance_eval "
            def self.get_gtype
              #{gtype}
            end
          "
        end

        # FIXME: Only used in some of the subclases. Make mixin?
        def provide_constructor
          return if info.find_method 'new'

          (class << @klass; self; end).class_eval {
            alias_method :new, :allocate
          }
        end

        def parent
          nil
        end

        def superclass
          unless defined? @superclass
            if parent
              @superclass = Builder.build_class parent
            else
              @superclass = GirFFI::ClassBase
            end
          end
          @superclass
        end
      end
    end
  end
end



