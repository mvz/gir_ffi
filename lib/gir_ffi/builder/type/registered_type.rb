require 'gir_ffi/builder/type/base'
require 'gir_ffi/class_base'

module GirFFI
  module Builder
    module Type

      # Base class for type builders building types specified by subtypes
      # of IRegisteredTypeInfo. These are types whose C representation is
      # complex, i.e., a struct or a union.
      class RegisteredType < Base
        private

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

        # TODO: Rename the created method, or use a constant.
        # FIXME: Only used in some of the subclases. Make mixin?
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



